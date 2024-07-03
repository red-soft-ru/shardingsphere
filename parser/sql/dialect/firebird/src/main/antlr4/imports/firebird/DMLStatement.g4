grammar DMLStatement;

import BaseRule;

dmlStatement
    : insert
    | update
    | delete
    | select
    ;

insert
    : INSERT INTO? tableName (insertValuesClause | insertSelectClause)
    ;

insertValuesClause
    : columnNames? (VALUES | VALUE) assignmentValues (COMMA_ assignmentValues)*
    ;

insertSelectClause
    : columnNames? select
    ;

update
    : UPDATE tableReferences setAssignmentsClause whereClause?
    ;

assignment
    : columnName EQ_ VALUES? LP_? assignmentValue RP_?
    ;

setAssignmentsClause
    : SET assignment (COMMA_ assignment)*
    ;

assignmentValues
    : LP_ assignmentValue (COMMA_ assignmentValue)* RP_
    | LP_ RP_
    ;

assignmentValue
    : expr | DEFAULT | blobValue
    ;

blobValue
    : STRING_
    ;

delete
    : DELETE singleTableClause whereClause?
    ;

singleTableClause
    : FROM tableName (AS? alias)?
    ;

select
    : withClause? combineClause
    ;

combineClause
    : selectClause (UNION (DISTINCT | ALL)? selectClause)*
    ;

selectClause
    : SELECT selectSpecification* projections fromClause? whereClause? groupByClause? havingClause? orderByClause? limitClause?
    ;

selectSpecification
    : duplicateSpecification
    ;

duplicateSpecification
    : ALL | DISTINCT
    ;

projections
    : (unqualifiedShorthand | projection) (COMMA_ projection)*
    ;

projection
    : (columnName | expr) (AS? alias)? | qualifiedShorthand
    ;

alias
    : identifier | STRING_
    ;

unqualifiedShorthand
    : ASTERISK_
    ;

qualifiedShorthand
    : identifier DOT_ASTERISK_
    ;

fromClause
    : FROM tableReferences
    ;

tableReferences
    : escapedTableReference (COMMA_ escapedTableReference)*
    ;

escapedTableReference
    : tableReference | LBE_ tableReference RBE_
    ;

tableReference
    : tableFactor joinedTable*
    ;

tableFactor
    : tableName (AS? alias)? | subquery (AS? alias)? columnNames? | LP_ tableReferences RP_
    ;

joinedTable
    : ((INNER | CROSS)? JOIN) tableFactor joinSpecification?
    | (LEFT | RIGHT) OUTER? JOIN tableFactor joinSpecification
    | NATURAL (INNER | (LEFT | RIGHT) (OUTER))? JOIN tableFactor
    ;

joinSpecification
    : ON expr | USING columnNames
    ;

whereClause
    : WHERE expr
    ;

groupByClause
    : GROUP BY orderByItem (COMMA_ orderByItem)*
    ;

havingClause
    : HAVING expr
    ;

limitClause
    : rowsClause | offsetDefinition
    ;

rowsClause
    : ROWS expr (TO expr)?
    ;

offsetDefinition
    : offsetClause? fetchClause?
    ;

offsetClause
    : OFFSET limitOffset (ROW | ROWS)
    ;

fetchClause
    : FETCH (FIRST | NEXT) limitRowCount (ROW | ROWS) ONLY
    ;

limitRowCount
    : numberLiterals | parameterMarker
    ;

limitOffset
    : numberLiterals | parameterMarker
    ;

subquery
    : LP_ combineClause RP_
    ;

withClause
    : WITH RECURSIVE? cteClause (COMMA_ cteClause)*
    ;

cteClause
    : identifier (LP_ columnNames RP_)? AS subquery
    ;
