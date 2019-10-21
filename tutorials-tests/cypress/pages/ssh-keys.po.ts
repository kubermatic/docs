import {Condition} from "../utils/condition";
import {wait} from "../utils/wait";

export class SshKeysPage {
  static visit(): void {
    cy.get('#km-nav-item-sshkeys').click();
    this.waitForRefresh();
    this.verifyUrl();
  }

  static waitForRefresh(): void {
    wait('**/sshkeys', 'GET', 'list sshkeys');
  }

  static getAddSshKeyInputName(): Cypress.Chainable<any> {
    return cy.get(`#name`);
  }

  static getAddSshKeyInputKey(): Cypress.Chainable<any> {
    return cy.get(`#key`);
  }

  static getAddSshKeyBtn(): Cypress.Chainable<any> {
    return cy.get('#km-add-ssh-key-top-btn');
  }

  static getAddSshKeyBtnSave(): Cypress.Chainable<any> {
    return cy.get('#km-add-ssh-key-dialog-save');
  }


  // Utils.

  static verifyUrl(): void {
    cy.url().should(Condition.Include, 'sshkeys');
  }
}