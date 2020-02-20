*&---------------------------------------------------------------------*
*&  Include           ZABAPTRRP14_JM_EVE
*&---------------------------------------------------------------------*

*Declara uma variável do tipo da classe
DATA:
      go_dependentes TYPE REF TO lcl_dependentes. "Classe local

START-OF-SELECTION.
* Cria uma instância do objeto do tipo da classe
  CREATE OBJECT go_dependentes.

GET peras. "Loop do banco de dados lógico (substitui um select * from PA0021 neste caso)

    go_dependentes->processa( ).

END-OF-SELECTION.

  go_dependentes->exibir( ).