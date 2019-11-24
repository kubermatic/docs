 /// <reference types="cypress" />
 import {Condition} from "../utils/condition";
 import {ProjectsPage} from "./projects.po";
 
 export class TutorialProjectsPage extends ProjectsPage {
   // main difference to projects.po: this selects the button not by id but by the text "Add Project"
   static getAddProjectBtn(): Cypress.Chainable<any> {
     return cy.contains('Add Project');
   }

   // Utils.

   static deleteProject(projectName: string): void {
     //added a manual visit of the projects page as otherwise local tests have occasionally stopped at this point
     this.visit();
     this.getDeleteProjectBtn(projectName).should(Condition.NotBe, 'disabled').click();
     cy.get('#km-confirmation-dialog-input').type(projectName).should(Condition.HaveValue, projectName);
     cy.get('#km-confirmation-dialog-confirm-btn').should(Condition.NotBe, 'disabled').click();
   }
 }
 
 