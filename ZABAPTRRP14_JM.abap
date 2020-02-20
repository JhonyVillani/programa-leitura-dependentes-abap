*&---------------------------------------------------------------------*
*& Report  ZABAPTRRP14_JM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zabaptrrp14_jm.

*Ao declarar este infotipo, obtemos de forma implícita a tabela p0021 com os dados retornados
INFOTYPES: 0021. "Infotipos relacionados

TABLES pernr. "Obrigatório

NODES peras. "Necessário declarar tipo de banco de dados lógico

*Estrutura para moldar tabela de saída do ALV
TYPES:
    BEGIN OF ty_s_dependentes,
      stext  TYPE t591s-stext,
      fcnam  TYPE pa0021-fcnam,
    END OF ty_s_dependentes.

DATA: gt_desc TYPE TABLE OF t591s.
DATA: gs_desc TYPE t591s.

DATA: mt_dados TYPE TABLE OF ty_s_dependentes.
DATA: ms_dados TYPE ty_s_dependentes.

START-OF-SELECTION.

*Select para popular uma tabela com as descrições, pois elas estão contidas em uma tabela à parte chamada t591s
  SELECT *
    FROM t591s
    INTO TABLE gt_desc
    WHERE sprsl EQ sy-langu AND infty = '0021'.

GET peras. "Loop do banco de dados lógico (substitui um select * from PA0021 neste caso)

  LOOP AT p0021.

*   Lê a primeira linha com subtipo igual na tabela populada por descrições
    READ TABLE gt_desc INTO gs_desc WITH KEY subty = p0021-subty.
    ms_dados-fcnam = p0021-fcnam.
    ms_dados-stext = gs_desc-stext.

    APPEND ms_dados TO mt_dados.
  ENDLOOP.

END-OF-SELECTION.

DATA: mo_alv TYPE REF TO cl_salv_table.
*   Criando o relatório ALV, declarando na classe a variáveis mo_alv referenciando cl_salv_table
*   Chama o método que constrói a saída ALV
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = mo_alv
    CHANGING
      t_table      = mt_dados.

*   Mostra o ALV
  mo_alv->display( ). "Imprime na tela do relatório ALV

  "rp_provide_from_last p0001 space pn-begda pn-endda. "OPCIONAL macro que retorna ultimo registro válido para um infotipo/subtipo