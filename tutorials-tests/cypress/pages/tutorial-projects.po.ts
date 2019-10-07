 /// <reference types="cypress" />
 import {Condition} from "../utils/condition";
 import {wait} from "../utils/wait";
 import {ClustersPage} from "./clusters.po";
 //TODO: deal with code redundancy from projects.po
 
 export class TutorialProjectsPage {
   static getProjectItem(projectName: string): Cypress.Chainable<any> {
     return cy.get(`#km-project-name-${projectName}`);
   }
 
   static getActiveProjects(): Cypress.Chainable<any> {
     return cy.get('i.km-health-state.fa.fa-circle.green');
   }
 
   // main difference to projects.po: this selects the button not by id but by the text "Add Project"
   static getAddProjectBtn(): Cypress.Chainable<any> {
     return cy.contains('Add Project');
   }
 
   static getAddProjectInput(): Cypress.Chainable<any> {
     return cy.get(`#km-add-project-dialog-input`);
   }
 
   static visit(): void {
     cy.get('#km-nav-item-projects').click();
     this.waitForRefresh();
     this.verifyUrl();
   }
 
   static verifyUrl(): void {
     cy.url().should(Condition.Include, 'projects');
   }
 
   static addProject(projectName: string): void {
     //this.visit();
     this.getAddProjectBtn().should(Condition.NotBe, 'disabled').click();
     this.getAddProjectInput().type(projectName).should(Condition.HaveValue, projectName);
     this.getAddProjectConfirmBtn().should(Condition.NotBe, 'disabled').click();
     this.waitForRefresh();
     this.getTable().should(Condition.Contain, projectName);
   }
   static selectProject(projectName: string): void {
     this.getProjectItem(projectName).should(Condition.HaveLength, 1);
     this.getActiveProjects().should(Condition.HaveLength, 1).click();
     ClustersPage.waitForRefresh();
     ClustersPage.verifyUrl();
   }
 
   static getAddProjectConfirmBtn(): Cypress.Chainable<any> {
     return cy.get(`#km-add-project-dialog-save`);
   }
 
   static getTable(): Cypress.Chainable<any> {
     return cy.get('tbody');
   }
 
   // Utils.
 
   
   static waitForRefresh(): void {
     wait('**/projects', 'GET', 'list projects');
   }
 
   static getDeleteProjectBtn(projectName: string): Cypress.Chainable<any> {
     return cy.get(`#km-delete-project-${projectName}`);
   }
 
   static deleteProject(projectName: string): void {
     this.visit();
     this.getDeleteProjectBtn(projectName).should(Condition.NotBe, 'disabled').click();
     cy.get('#km-confirmation-dialog-input').type(projectName).should(Condition.HaveValue, projectName);
     cy.get('#km-confirmation-dialog-confirm-btn').should(Condition.NotBe, 'disabled').click();
   }
 }
 
 