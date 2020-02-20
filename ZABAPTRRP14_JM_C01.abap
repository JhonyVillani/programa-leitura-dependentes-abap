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
          pernr TYPE pa0002-pernr,
          cname TYPE pa0002-cname,
          stext TYPE t591s-stext,
          fcnam TYPE pa0021-fcnam,
          fgbdt TYPE pa0021-fgbdt,
          salfa TYPE p0397-salfa,
          irflg TYPE p0397-irflg,
          estud TYPE p0397-estud,
          icnum TYPE p0397-icnum,

        END OF ty_s_dependentes.

*   Variável tabela interna e estrutura que contém a descrição
    DATA: gt_desc TYPE TABLE OF t591s.
    DATA: gs_desc TYPE t591s.

*   Variável tabela interna final e estrutura que serão passadas para o ALV
    DATA: mt_dados TYPE TABLE OF ty_s_dependentes.
    DATA: ms_dados TYPE ty_s_dependentes.

*   Variável obrigatória para chamar a função do ALV
    DATA: mo_alv     TYPE REF TO cl_salv_table,
          go_columns TYPE REF TO cl_salv_columns_table,
          go_zebra   TYPE REF TO cl_salv_display_settings.

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

    DATA: ls_p0021 TYPE p0021, "Estrutura que trabalha com o infotipo
          ls_p0002 TYPE p0002, "Estrutura que trabalha com o infotipo
          ls_p0397 TYPE p0397. "Estrutura que trabalha com o infotipo

    LOOP AT p0021 INTO ls_p0021.
*     Lê a primeira linha com subtipo igual na tabela populada por descrições
      READ TABLE gt_desc INTO gs_desc WITH KEY subty = ls_p0021-subty.

*     Lendo a tabela pa0002 e para o primeiro registro trazer a matrículao e nome (index funciona porque só há uma pessoa associada aos dependentes)
      READ TABLE p0002 INTO ls_p0002 INDEX 1.

*     Lendo a tabela pa0397 e para o primeiro registro e se possui mais um registro do mesmo tipo
      READ TABLE p0397 INTO ls_p0397 WITH KEY subty = ls_p0021-subty "valida se é o mesmo subty
                                              objps = ls_p0021-objps."valida se possui mais de um objeto (continuação), caso contrário vai pular dados

      ms_dados-pernr = ls_p0002-pernr. "p0002
      ms_dados-cname = ls_p0002-cname. "p0002

      ms_dados-fcnam = ls_p0021-fcnam. "p0021
      ms_dados-stext = gs_desc-stext.  "p0021
      ms_dados-fgbdt = ls_p0021-fgbdt. "p0021

      ms_dados-salfa = ls_p0397-salfa. "p0397
      ms_dados-irflg = ls_p0397-irflg. "p0397
      ms_dados-estud = ls_p0397-estud. "p0397
      ms_dados-icnum = ls_p0397-icnum. "p0397

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

* Otimiza tamanho das colunas
    go_columns = mo_alv->get_columns( ). "Retorna o objeto tipo coluna INSTANCIADO
    go_columns->set_optimize( ).

* Zebrar report
    go_zebra = mo_alv->get_display_settings( ).
    go_zebra->set_striped_pattern( abap_true ).

*   Mostra o ALV
    mo_alv->display( ). "Imprime na tela do relatório ALV

  ENDMETHOD.                    "exibir

ENDCLASS.                    "lcl_dependentes IMPLEMENTATION