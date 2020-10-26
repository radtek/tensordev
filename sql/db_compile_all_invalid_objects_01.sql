-- -----------------------------------------------------------------------------------
-- File Name    : db_compile_all_invalid_objects_01.sql
-- Description  : Scripts para compilar todos os objetos inv�lidos
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_compile_all_invalid_objects_01.sql
-- Last Modified: 02/04/2012
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON SIZE 1000000;
--
declare

	v_qt_compilacao			number	:=	1;
	v_qt_limite_compilacoes		number	:=	10;
	v_qt_objetos_invalidos_antes	number;
	v_qt_objetos_invalidos_depois	number;
	v_id_novo_objeto_invalido	varchar2(1);
	v_saida_anormal			exception;
	type	v_type_objetos		is	record
	(
		owner			varchar2(30),
		object_name		varchar2(30),
		object_type		varchar2(18),
		sqlerrm			varchar2(255),
		continua_invalido	varchar2(1)
	);
	type	v_table_objetos		is	table	of	v_type_objetos;
	v_objetos			v_table_objetos;

procedure	prc_compila_invalidos	(p_qt_objetos_invalidos_antes	out	number
					,p_qt_objetos_invalidos_depois	out	number
					,p_id_novo_objeto_invalido	out	varchar2)	is

	--	Busca os objetos inv�lidos do ambiente
	cursor	c01	is
		select	owner,
			object_name,
			object_type,
			decode	(object_type,	'VIEW',		0,
						'FUNCTION',	1,
						'PACKAGE',	2,
						'PACKAGE BODY',	3,
						'PROCEDURE',	4,	5)	recompile_order
		from	all_objects
		where	object_type	in	('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION','VIEW')
		and	owner		=	'AMLP'
		and	status		!=	'VALID'
		order	by	recompile_order;

	i_objetos			number;

begin

	v_objetos	:=	v_table_objetos();

	--	Processa todos os objetos inv�lidos do ambiente e compila cada um
	for	r01	in	c01	loop

		--	Guarda todos os objetos inv�lidos em mem�ria
		v_objetos.extend;
		v_objetos(v_objetos.count).owner		:=	r01.owner;
		v_objetos(v_objetos.count).object_name		:=	r01.object_name;
		v_objetos(v_objetos.count).object_type		:=	r01.object_type;
		v_objetos(v_objetos.count).sqlerrm		:=	null;
		v_objetos(v_objetos.count).continua_invalido	:=	'N';

		--	Compila o objeto
		begin
			if	r01.object_type	=	'PACKAGE'	then
				execute	immediate	'ALTER '		||
							r01.object_type		||
							' "'			||
							r01.owner		||
							'"."'			||
							r01.object_name		||
							'" COMPILE';
			elsif	r01.object_type	=	'PACKAGE BODY'	then
				execute	immediate	'ALTER PACKAGE "'	||
							r01.owner		||
							'"."'			||
							r01.object_name		||
							'" COMPILE BODY';
			elsif	r01.object_type	=	'FUNCTION'	then
				execute	immediate	'ALTER FUNCTION "'	||
							r01.owner		||
							'"."'			||
							r01.object_name		||
							'" COMPILE';
			elsif	r01.object_type	=	'VIEW'		then
				execute immediate	'ALTER VIEW "'		||
							r01.owner		||
							'"."'			||
							r01.object_name		||
							'" COMPILE';
			else
				execute	immediate	'ALTER PROCEDURE "'	||
							r01.owner		||
							'"."'			||
							r01.object_name		||
							'" COMPILE';
			end if;
		exception
			when	others	then
				v_objetos(v_objetos.count).sqlerrm		:=	substr(sqlerrm,1,255);
				v_objetos(v_objetos.count).continua_invalido	:=	'S';
		end;

	end	loop;

	--	Verifica se os objetos inv�lidos restantes s�o os mesmos que os anteriores
	p_id_novo_objeto_invalido	:=	'N';
	p_qt_objetos_invalidos_antes	:=	v_objetos.count;
	p_qt_objetos_invalidos_depois	:=	0;
	for	r01	in	c01	loop
		p_qt_objetos_invalidos_depois	:=	p_qt_objetos_invalidos_depois	+	1;
		i_objetos			:=	1;
		while	(i_objetos		<=	v_objetos.count		and
			(r01.owner		!=	v_objetos(i_objetos).owner		or
			r01.object_name		!=	v_objetos(i_objetos).object_name	or
			r01.object_type		!=	v_objetos(i_objetos).object_type))	loop
			i_objetos		:=	i_objetos		+	1;
		end	loop;
		if	i_objetos	>	v_objetos.count	then
			--	H� um novo objeto inv�lido ap�s a compila��o, portanto, ser� necess�ria nova compila��o
			p_id_novo_objeto_invalido	:=	'S';
			v_objetos.extend;
			v_objetos(v_objetos.count).owner		:=	r01.owner;
			v_objetos(v_objetos.count).object_name		:=	r01.object_name;
			v_objetos(v_objetos.count).object_type		:=	r01.object_type;
			v_objetos(v_objetos.count).sqlerrm		:=	null;
			v_objetos(v_objetos.count).continua_invalido	:=	'S';
		else
			v_objetos(i_objetos).continua_invalido	:=	'S';
		end	if;
	end	loop;

end	prc_compila_invalidos;

begin

	prc_compila_invalidos	(p_qt_objetos_invalidos_antes	=>	v_qt_objetos_invalidos_antes
				,p_qt_objetos_invalidos_depois	=>	v_qt_objetos_invalidos_depois
				,p_id_novo_objeto_invalido	=>	v_id_novo_objeto_invalido);

	--	Executa compila��es sucessivas enquanto
	--	1. houver objetos inv�lidos									E
	--	2. (a quantidade de objetos inv�lidos tiver sido alterada OU existir um novo objeto inv�lido)	E
	--	3. n�o tiver sido atingido o limite m�ximo de compila��es
	while	(v_qt_objetos_invalidos_depois	!=	0				and
		(v_qt_objetos_invalidos_antes	!=	v_qt_objetos_invalidos_depois	or
		v_id_novo_objeto_invalido	=	'S')				and
		v_qt_compilacao			<	v_qt_limite_compilacoes)	loop

		prc_compila_invalidos	(p_qt_objetos_invalidos_antes	=>	v_qt_objetos_invalidos_antes
					,p_qt_objetos_invalidos_depois	=>	v_qt_objetos_invalidos_depois
					,p_id_novo_objeto_invalido	=>	v_id_novo_objeto_invalido);

		v_qt_compilacao	:=	v_qt_compilacao	+	1;

	end	loop;

	dbms_output.put_line	('Quantidades de Compila��es: '		||	v_qt_compilacao);
	dbms_output.put_line	('Objetos Inv�lidos Restantes: '	||	v_qt_objetos_invalidos_depois);
	if	v_qt_objetos_invalidos_depois	!=	0	then
		dbms_output.put_line	('Listagem de objetos inv�lidos restantes:');
		for	i	in	1..v_objetos.count	loop
			if	v_objetos(i).continua_invalido	=	'S'	then
				dbms_output.put_line	(	substr
							(	v_objetos(i).object_type	||	';'
							||	v_objetos(i).owner		||	';'
							||	v_objetos(i).object_name	||	';'
							||	v_objetos(i).sqlerrm,	1,	255));
			end	if;
		end	loop;
	end	if;

	if	v_qt_objetos_invalidos_depois	!=	0				and
		(v_qt_objetos_invalidos_antes	!=	v_qt_objetos_invalidos_depois	or
		v_id_novo_objeto_invalido	=	'S')				and
		v_qt_compilacao			>=	v_qt_limite_compilacoes		then
		dbms_output.put_line	(	'Aten��o! '
					||	v_qt_limite_compilacoes
					||	' compila��es n�o foram suficientes para compilar todos os objetos inv�lidos! Contatar o analista!');
		raise	v_saida_anormal;
	end	if;

end;
/
