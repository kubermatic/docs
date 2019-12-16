import {TutorialProjectsPage} from "../../pages/tutorial-projects.po";
import {login, logout} from "../../utils/auth";
import {Condition} from "../../utils/condition";
import {prefixedString} from "../../utils/random";
import {SshKeysPage} from "../../pages/ssh-keys.po";
import {ClustersPage} from "../../pages/clusters.po";
import {WizardPage} from "../../pages/wizard.po";
import {wait} from "../../utils/wait";
import {Datacenter, Provider} from "../../utils/provider";
import {NodeDeploymentDetailsPage} from "../../pages/node-deployment-details.po";
 
describe('Tutorials Story', () => {
  const email = Cypress.env('KUBERMATIC_DEX_DEV_E2E_USERNAME');
  const password = Cypress.env('KUBERMATIC_DEX_DEV_E2E_PASSWORD');
  let projectName = prefixedString('e2e-test-project');
  const sshKeyName = "test-key"
  const sshKey = Cypress.env('SSH_RSA_KEY');
  const clusterName = prefixedString('e2e-test-cluster');
  const digitaloceanToken = Cypress.env('DO_E2E_TESTS_TOKEN');
  const initialNodeDeploymentName = prefixedString('e2e-test-nd');
  const initialNodeDeploymentReplicas = '1';
  
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

  // only adding, no deletion since it's not part of the tutorial 
  // and the key gets deleted with the project anyway
  it('tutorials 02: should add SSH key', () => {
    TutorialProjectsPage.selectProject(projectName);
    SshKeysPage.visit();
    SshKeysPage.verifyUrl();
    SshKeysPage.getAddSshKeyBtn().should(Condition.Contain, "Add SSH Key").click();
    SshKeysPage.getAddSshKeyInputName().type(sshKeyName).should(Condition.HaveValue, sshKeyName);
    SshKeysPage.getAddSshKeyInputKey().type(sshKey).should(Condition.HaveValue, sshKey);
    SshKeysPage.getAddSshKeyBtnSave().should(Condition.Contain, "Add SSH key").should(Condition.NotBe, 'disabled').click();
  });

  it('tutorials 03: should create a new cluster', () => {
    ClustersPage.visit();
    ClustersPage.openWizard();
    WizardPage.getClusterNameInput().type(clusterName).should(Condition.HaveValue, clusterName);
    WizardPage.getNextBtn().click();
    WizardPage.getProviderBtn(Provider.Digitalocean).click();
    WizardPage.getDatacenterBtn(Datacenter.Frankfurt).click();
    WizardPage.getDigitalOceanTokenInput().type(digitaloceanToken).should(Condition.HaveValue, digitaloceanToken);
    wait('**/providers/digitalocean/sizes');
    WizardPage.getNodeNameInput().type(initialNodeDeploymentName).should(Condition.HaveValue, initialNodeDeploymentName);
    WizardPage.getNodeCountInput().clear().type(initialNodeDeploymentReplicas).should(Condition.HaveValue, initialNodeDeploymentReplicas);
    WizardPage.getNextBtn().click();
    WizardPage.getCreateBtn().click();
    cy.url().should(Condition.Contain, '/clusters');
  });

  it('should check if cluster was created', () => {
    ClustersPage.visit();
    ClustersPage.getTable().should(Condition.Contain, clusterName);
  });

  it('tutorials 08.1: should update node deployments', () => {
    ClustersPage.getClusterItem(clusterName).click();
    wait('**/nodedeployments', 'GET', 'getNodeDeployments', 900000);
    cy.get('kubermatic-node-deployment-list', {timeout: 900000}).should(Condition.Contain, initialNodeDeploymentName);
    ClustersPage.getTableRowNodeDeploymentNameColumn(initialNodeDeploymentName).click();
    NodeDeploymentDetailsPage.getNodeDeploymentNameElement().should(Condition.Contain, initialNodeDeploymentName);
    NodeDeploymentDetailsPage.getNodeDeploymentClusterNameElement().should(Condition.Contain, clusterName);

  });


  it('tutorials 08.2: should go back to cluster details page and remove initial node deployment', () => {
    NodeDeploymentDetailsPage.getBackToClusterBtn().click();
    cy.url().should(Condition.Contain, '/clusters');
    cy.get('mat-card-title').should(Condition.Contain, clusterName);
    cy.get('kubermatic-node-deployment-list').should(Condition.Contain, initialNodeDeploymentName);

    ClustersPage.getNodeDeploymentRemoveBtn(initialNodeDeploymentName).click();
    ClustersPage.getDeleteNodeDeploymentDialogBtn().click();
    ClustersPage.getTableRowNodeDeploymentNameColumn(initialNodeDeploymentName).should(Condition.NotExist);
  });

  it('should delete created cluster', () => {
    ClustersPage.visit();
    ClustersPage.getClusterItem(clusterName).click();
    ClustersPage.deleteCluster(clusterName);
  });

  it('should verify that there are no clusters', () => {
    ClustersPage.verifyNoClusters();
  });
   
  it('tutorials 01.2: should delete the project', () => {
    TutorialProjectsPage.visit();
    TutorialProjectsPage.selectProject(projectName);
    TutorialProjectsPage.deleteProject(projectName);
    logout();
  });  
});
