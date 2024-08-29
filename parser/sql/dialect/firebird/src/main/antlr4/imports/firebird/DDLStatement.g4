/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

grammar DDLStatement;

import DMLStatement;

createTable
    : CREATE createTemporaryTable? TABLE tableName createDefinitionClause sqlSecurity?
    ;

createCollation
    : CREATE COLLATION collationName FOR characterSetName fromCollationClause? paddingClause? caseSensitivityClause? accentSensitivityClause? attributeClause?
    ;

fromCollationClause
    : FROM baseSortName | FROM EXTERNAL LP_ STRING_ RP_
    ;

paddingClause
    : NO PAD | PAD SPACE
    ;

caseSensitivityClause
    : CASE SENSITIVE | CASE INSENSITIVE
    ;

accentSensitivityClause
    : ACCENT SENSITIVE | ACCENT INSENSITIVE
    ;

attributeClause
    : attributeCollation (SEMI_ attributeCollation)*
    ;

createDomain
    : CREATE DOMAIN domainName AS? dataType defaultClause? notNullClause? checkClause? characterSetClause?
    ;

defaultClause
    : DEFAULT defaultValue?
    ;

notNullClause
    : NOT NULL
    ;

checkClause
    : CHECK LP_ predicate RP_
    ;

characterSetClause
    : CHARACTER SET characterSetName collateClause?
    ;

alterTable
    : ALTER TABLE tableName alterDefinitionClause
    ;

alterSequence
    : ALTER SEQUENCE tableName sequenceRestartClause? sequenceIncrementClause?
    ;

createSequence
    : CREATE (GENERATOR | SEQUENCE) tableName sequenceRestartClause? sequenceIncrementClause?
    ;

alterDomain
    : ALTER DOMAIN domainName toTableClause? defaultAlterDomainClause? notNullAlterDomainClause? constraintClause? typeClause?
    ;

toTableClause
    : TO tableName
    ;

defaultAlterDomainClause
    : (SET DEFAULT defaultValue | DROP DEFAULT)
    ;

notNullAlterDomainClause
    : (SET | DROP) NOT NULL
    ;

constraintClause
    : (ADD CONSTRAINT? CHECK LP_ predicate RP_ | DROP CONSTRAINT)
    ;

typeClause
    : TYPE dataType (CHARACTER SET literals (COLLATE sortOrder)?)?
    ;

dropTable
    : DROP TABLE tableNames dropBehaviour
    ;

createFunction
    : CREATE FUNCTION functionName
      inputArgumentClause?
      RETURNS typeDescriptionArgument
      collateClause?
      DETERMINISTIC?
      (
          EXTERNAL NAME externalModuleName ENGINE engineName
      |
          (SQL SECURITY (DEFINER | INVOKER))?
          AS
          announcementClause?
          BEGIN
              statementBlock
          END
      )
    ;

statementBlock
    : (statement SEMI_?)*
    ;

statement
    : select
    | insert
    | update
    | delete
    | returnStatement
    | cursorOpenStatement
    | cursorCloseStatement
    | ifStatement
    ;

cursorOpenStatement
    : OPEN cursorName
    ;

cursorCloseStatement
    : CLOSE cursorName
    ;

announcementClause
    : announcement (COMMA_ announcement)*
    ;

announcement
    : localVariableAnnouncement
    | cursorAnnouncement
    | procedureAnnouncement
    | functioneAnnouncement
    ;

localVariableAnnouncement
    : DECLARE VARIABLE? (
    localVariableDeclarationName typeDescriptionArgument
    (NOT NULL)?
    collateClause?
    ((EQ_ | DEFAULT) defaultValue)?
    | cursorName CURSOR FOR LP_ select RP_ SEMI_?
    )
    ;

cursorAnnouncement
    :  DECLARE VARIABLE? cursorName
    CURSOR FOR (SCROLL | NO SCROLL)? LP_ select RP_ SEMI_?
    ;

procedureAnnouncement
    : PROCEDURE procedureName inputArgumentClause? (RETURNS inputArgumentClause)?
    ;

functioneAnnouncement
    : FUNCTION functionName inputArgumentClause? RETURNS typeDescriptionArgument collateClause? DETERMINISTIC?
    ;

inputArgument
    : announcementArgument ((EQ_ | DEFAULT) defaultValue)?
    ;

inputArgumentClause
    : LP_ (inputArgument (COMMA_ inputArgument)*)? RP_
    ;

createDatabase
    : CREATE SCHEMA schemaName createDatabaseSpecification_*
    ;

dropDatabase
    : DROP SCHEMA schemaName dropBehaviour
    ;

createView
    : CREATE VIEW viewName (LP_ identifier (COMMA_ identifier)* RP_)?
      AS select
      (WITH (CASCADED | LOCAL)? CHECK OPTION)?
    ;

dropView
    : DROP VIEW viewName dropBehaviour
    ;

createTemporaryTable
    : GLOBAL TEMPORARY
    ;

sqlSecurity
    : SQL SECURITY (DEFINER | INVOKER)
    ;

createDefinitionClause
    : LP_ createDefinition (COMMA_ createDefinition)* RP_
    ;

sequenceRestartClause
    : RESTART (WITH bitExpr)?
    ;

sequenceIncrementClause
    : INCREMENT BY? NUMBER_
    ;

createDatabaseSpecification_
    : DEFAULT CHARACTER SET EQ_? characterSetName
    ;

createDefinition
    : columnDefinition | constraintDefinition | checkConstraintDefinition
    ;

columnDefinition
    : columnName dataType dataTypeOption*
    ;

dataTypeOption
    : primaryKey usingDefinition?
    | UNIQUE usingDefinition?
    | NOT? NULL
    | collateClause
    | checkConstraintDefinition
    | referenceDefinition
    | DEFAULT (literals | expr)
    | STRING_
    ;

checkConstraintDefinition
    : (CONSTRAINT ignoredIdentifier?)? CHECK expr
    ;

referenceDefinition
    : REFERENCES tableName columnNames? usingDefinition? (ON (UPDATE | DELETE) referenceOption)*
    ;

referenceOption
    : CASCADE | SET NULL | NO ACTION | SET DEFAULT
    ;

usingDefinition
    : USING (ASC(ENDING)? | DESC(ENDING)?)? INDEX identifier
    ;

constraintDefinition
    : (CONSTRAINT constraintName?)? (primaryKeyOption | uniqueOption | foreignKeyOption)
    ;

primaryKeyOption
    : primaryKey columnNames usingDefinition?
    ;

primaryKey
    : PRIMARY KEY
    ;

uniqueOption
    : UNIQUE columnNames usingDefinition?
    ;

foreignKeyOption
    : FOREIGN KEY columnNames referenceDefinition
    ;

createLikeClause
    : LP_? LIKE tableName RP_?
    ;


alterDefinitionClause
    : addColumnSpecification
    | modifyColumnSpecification
    | dropColumnSpecification
    | addConstraintSpecification
    | dropConstraintSpecification
    ;

addColumnSpecification
    : ADD COLUMN? columnDefinition
    ;

modifyColumnSpecification
    : modifyColumn (TO tableName
                  | POSITION expr
                  | TYPE (dataType | domainName)
                  | SET DEFAULT defaultValue
                  | DROP DEFAULT
                  | SET NOT NULL
                  | DROP NOT NULL
                  | (TYPE dataType)? (GENERATED ALWAYS AS | COMPUTED BY?) LP_ expr RP_
                  | RESTART (WITH NUMBER_)?
                  )
    ;

modifyColumn
    : ALTER COLUMN? columnName
    ;

dropColumnSpecification
    : DROP COLUMN? columnName
    ;

addConstraintSpecification
    : ADD constraintDefinition
    ;

dropConstraintSpecification
    : DROP constraintDefinition
    ;

returnStatement
    : RETURN expr
    ;

createProcedure
    : CREATE PROCEDURE procedureName (AUTHID (OWNER | CALLER))?
        inputArgumentClause?
        (RETURNS announcementArgument)?
        (
            EXTERNAL NAME externalModuleName ENGINE engineName
        |
            (SQL SECURITY (DEFINER | INVOKER))?
            AS
            announcementClause?
            BEGIN
                statementBlock
            END
        )
    ;

createTrigger
    : CREATE TRIGGER triggerName triggerClause
    ;

alterTrigger
    : ALTER TRIGGER triggerName (ACTIVE | INACTIVE)? ((BEFORE | AFTER) eventListTable)? (POSITION expr)? triggerClause
    ;

createOrAlterTrigger
    : CREATE OR ALTER TRIGGER triggerName triggerClause
    ;

announcmentTriggerClause
    : (
                announcmentTableTrigger |
                announcmentTableTriggerSQL_2003Standart |
                announcmentDataBaseTrigger |
                announcmentDDLTrigger
                )
    ;

triggerClause
    : announcmentTriggerClause?
          (
                EXTERNAL NAME externalModuleName ENGINE engineName
            |
                (SQL SECURITY (DEFINER | INVOKER) | DROP SQL SECURITY)?
                AS
                announcementClause?
                BEGIN
                    statementBlock
                END
          )
    ;

announcmentTableTrigger
    : FOR (tableName | viewName)
    (ACTIVE | INACTIVE)?
    (BEFORE | AFTER) eventListTable
    (POSITION expr)?
    ;

eventListTable
    : dmlStatement (OR dmlStatement)*
    ;

listDDLStatement
    : ANY DDL STATEMENT
    | ddlStatement (OR ddlStatement)*
    ;

dmlStatement
    : INSERT | UPDATE | DELETE
    ;

ddlStatement
    : (CREATE | ALTER | DROP) TABLE
    | (CREATE | ALTER | DROP) PROCEDURE
    | (CREATE | ALTER | DROP) FUNCTION
    | (CREATE | ALTER | DROP) TRIGGER
    | (CREATE | ALTER | DROP) EXCEPTION
    | (CREATE | ALTER | DROP) VIEW
    | (CREATE | ALTER | DROP) DOMAIN
    | (CREATE | ALTER | DROP) ROLE
    | (CREATE | ALTER | DROP) SEQUENCE
    | (CREATE | ALTER | DROP) USER
    | (CREATE|ALTER|DROP) INDEX
    | (CREATE | DROP) COLLATION
    | ALTER CHARACTER SET
    | (CREATE | ALTER | DROP) PACKAGE
    | (CREATE | DROP) PACKAGE BODY
    | (CREATE | ALTER | DROP) MAPPING
    ;

announcmentTableTriggerSQL_2003Standart
    : (ACTIVE | INACTIVE)?
      (BEFORE | AFTER) eventListTable
      (POSITION expr)?
      ON (tableName | viewName)
    ;

announcmentDataBaseTrigger
    : (ACTIVE | INACTIVE)?
      ON eventConnectOrTransaction
      (POSITION expr)?
    ;

eventConnectOrTransaction
    : CONNECT
    | DISCONNECT
    | TRANSACTION START
    | TRANSACTION COMMIT
    | TRANSACTION ROLLBACK
    ;

announcmentDDLTrigger
    : (ACTIVE | INACTIVE)?
      (BEFORE | AFTER) listDDLStatement
      (POSITION expr)?
    ;

executeBlock
    : EXECUTE BLOCK
    inputArgumentList?
        (RETURNS LP_ outputArgumentList RP_)?
    AS
        announcementClause?
    BEGIN
        statementBlock
    END SEMI_
    ;

inputArgumentList
    : LP_ announcementArgument EQ_ QUESTION_  (COMMA_ (announcementArgument EQ_ QUESTION_))* RP_
    ;

outputArgumentList
    : announcementArgumentClause
    ;

ifStatement
    :
     IF LP_ predicate RP_
     THEN beginStatement+
     (ELSE beginStatement+)?
    ;

compoundStatement
    : (createTable | alterTable | dropTable | dropDatabase | insert | update | delete | select | createView | beginStatement | transferOperator | assignmentStatement) SEMI_?
    ;

beginStatement
    : BEGIN compoundStatement* END SEMI_?
    ;

transferOperator
    : SUSPEND
    ;

assignmentStatement
    : variableName EQ_ simpleExpr
    ;
