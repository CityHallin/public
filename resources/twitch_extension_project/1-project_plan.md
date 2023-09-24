# Twitch Extension Application Project Plan

- [Project Overview](./1-project_plan.md)
- [Project Resources](./2-resources.md)
- [Project Testing](./3-testing.md)

## Project Overview
This proof-of-concept project is a simple demonstration of a Twitch Extension application used on a streamer's Twitch channel that viewers can interact with in order to increase engagement on a stream. The idea for this project is that on the stream, the streamer would display questions while running the stream. The viewers would then interact with the Twitch Extension application to submit their answers. The Twitch Extension application sends these answers to Azure services to be processes and return information to the viewer. 

## Contributors
This is a research project involving the following community members:
- @CityHallin: Cloud engineering and integration.
- @Regentine: Application design and software development.

## Current Scope
- This is only a proof-of-concept project used to learn more about Twitch's integration with other 3rd-party services. This will be used in a limited capacity with select Twitch channels and not meant for public use at this time. 

- The frontend application will have limited functionality just answering a single question to demonstrate connectivity to Azure services.

- The frontend application does not currently have any styling in order to simplify the research process. 

## Future Scope
If we decide to build out this application for expanded future use, here are some of the features and functionality we will be investigating:
- Adding a separate function to query game progression and automatically update another web frontend the presenter can add to their stream to display information to viewers. 

- Adding OAuth authorization functionality to the frontend Twitch Extension application used to capture public Twitch user information saved to the database for leader board status. 

- Update existing function that will update game status in the database for question progression. 

- Adding styling to the frontend Twitch Extension application. 

- Expand the current list of question/answer pairs and add a workflow for the stream operator to update question/answer pairs efficiently. 

## Security
Investigating the following measures to increase the security of this application workflow:
- All communication will use TLS encryption via HTTPS and public certificate authorities. 

- The frontend Twitch Extension application will not store any sensitive, stateful data. Twitch-provided **Helper Functions** will ensure the Javascript being used can only work from code running in Twitch's backend and will only work with our allowed Twitch Extension application profiles. 

- All functions in Azure Functions Apps will be required to use the **function** authentication configuration. This will force all backend API interaction to authenticate via function keys. 

- Azure Functions Apps will sit behind **API Management Services (APIM)**. 

- The APIM will require the frontend Twitch Extension application to send **JSON Web Tokens (JWT)** in its HTTP POST headers fitting a specific header scheme. The JWT's signature will be validated by the APIM inbound policies and only specific signatures from approved Twitch Extension applications will be allowed to pass to the backend Azure Function App APIs. 

- APIM **CORS Policies** will only allow specific origin URLs and approved headers to pass to the backend APIs. 

- The database-integrated firewall will only allow Layer 4 access to our Azure tenant's Azure services and select IP address ranges for the project contributors.  

View the [Project Resources](./2-resources.md)