*&---------------------------------------------------------------------*
*&  Include           ZABAPTRRP14_JM_C01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_dependentes DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_dependentes DEFINITION.
  PUBLIC SECTION.
*   Estrutura para moldar tabela de saída do ALV
    TYPES:
        BEGIN OF ty_s_dependentes,
          stext  TYPE t591s-stext,
          fcnam  TYPE pa0021-fcnam,
        END OF ty_s_dependentes.

*   Variável tabela interna e estrutura que contém a descrição
    DATA: gt_desc TYPE TABLE OF t591s.
    DATA: gs_desc TYPE t591s.

*   Variável tabela interna final e estrutura que serão passadas para o ALV
    DATA: mt_dados TYPE TABLE OF ty_s_dependentes.
    DATA: ms_dados TYPE ty_s_dependentes.

*   Variável obrigatória para chamar a função do ALV
    DATA: mo_alv TYPE REF TO cl_salv_table.

    METHODS:
   constructor,
   processa,
   exibir.

ENDCLASS.                    "lcl_dependentes DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_dependentes IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_dependentes IMPLEMENTATION.
  METHOD constructor.

*Select para popular uma tabela com as descrições, pois elas estão contidas em uma tabela à parte chamada t591s
    SELECT *
    FROM t591s
    INTO TABLE gt_desc
    WHERE sprsl EQ sy-langu AND infty = '0021'.

  ENDMETHOD.                    "constructor

  METHOD processa.

DATA: ls_p0021 TYPE p0021.

    LOOP AT p0021 INTO ls_p0021.
*   Lê a primeira linha com subtipo igual na tabela populada por descrições
      READ TABLE gt_desc INTO gs_desc WITH KEY subty = ls_p0021-subty.
      ms_dados-fcnam = ls_p0021-fcnam.
      ms_dados-stext = gs_desc-stext.

      APPEND ms_dados TO mt_dados.
    ENDLOOP.

  ENDMETHOD.                    "processa

  METHOD exibir.

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

  ENDMETHOD.                    "exibir

ENDCLASS.                    "lcl_dependentes IMPLEMENTATION