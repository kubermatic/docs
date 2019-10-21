import {TutorialProjectsPage} from "../../pages/tutorial-projects.po";
import {login, logout} from "../../utils/auth";
import {Condition} from "../../utils/condition";
import {prefixedString} from "../../utils/random";
import {SshKeysPage} from "../../pages/ssh-keys.po";
 
describe('Tutorials Story', () => {
  const email = Cypress.env('KUBERMATIC_DEX_DEV_E2E_USERNAME');
  const password = Cypress.env('KUBERMATIC_DEX_DEV_E2E_PASSWORD');
  let projectName = prefixedString('e2e-test-project');
  const sshKeyName = "test-key"
  const sshKey = Cypress.env('SSH_RSA_KEY');
  
  before(() => {
    cy.clearCookies();
  });
   
  beforeEach(() => {
    cy.server();
    Cypress.Cookies.preserveOnce('token', 'nonce');
  });
  
  it('tutorials 01.1: should create a new project', () => {
    login(email, password);
    cy.url().should(Condition.Include, 'projects');
    TutorialProjectsPage.addProject(projectName);
  });

  it('should select project', () => {
    TutorialProjectsPage.selectProject(projectName);
  });

  // only adding, no deletion since it's not part of the tutorial 
  // and the key gets deleted with the project anyway
  it('tutorials 02: should add SSH key', () => {
    SshKeysPage.visit();
    SshKeysPage.verifyUrl();
    SshKeysPage.getAddSshKeyBtn().should(Condition.Contain, "Add SSH Key").click();
    SshKeysPage.getAddSshKeyInputName().type(sshKeyName).should(Condition.HaveValue, sshKeyName);
    SshKeysPage.getAddSshKeyInputKey().type(sshKey).should(Condition.HaveValue, sshKey);
    SshKeysPage.getAddSshKeyBtnSave().should(Condition.Contain, "Add SSH key").should(Condition.NotBe, 'disabled').click();
  });
   
  it('tutorials 01.2: should delete the project', () => {
    TutorialProjectsPage.visit();
    TutorialProjectsPage.selectProject(projectName);
    TutorialProjectsPage.deleteProject(projectName);
    logout();
  });  
});
 