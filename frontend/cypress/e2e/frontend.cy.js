describe('Frontend-Backend Integration Test', () => {
  it('should load the frontend and display the backend status and message', () => {
    cy.visit('http://localhost:3000');

    cy.contains('DevOps Assignment');
    cy.contains('Status: Backend is connected!').should('exist');
    cy.contains("You've successfully integrated the backend!").should('exist');
  });
});
