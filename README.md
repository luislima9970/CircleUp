# _CircleUP_ Development Report

Welcome to the documentation of _CircleUP_!

This Software Development Report, tailored for LEIC-ES-2025-26, provides comprehensive details about _CircleUP_, starting from an high-level vision and going into low-level implementation decisions. 

It is organised by the following activities: 

* [Business modeling](#Business-Modelling) 
  * [Product Vision](#Product-Vision)
  * [Features and Assumptions](#Features-and-Assumptions)
* [Requirements](#Requirements)
  * [User stories](#User-stories)
  * [Domain model](#Domain-model)
  * [User interfaces](#User-interfaces)
* [Architecture and Design](#Architecture-And-Design)
  * [Logical architecture](#Logical-Architecture)
  * [Physical architecture](#Physical-Architecture)
  * [Functional prototype](#Functional-Prototype)
* [Project management](#Project-Management)
  * [Sprint 0](#Sprint-0)
  * [Sprint 1](#Sprint-1)
  * [Sprint 2](#Sprint-2)
  * [Sprint 3](#Sprint-3)
  * [Final Release](#Final-Release)

Contributions are expected to be made exclusively by the initial team, but we may open them to the community, after the course, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us!

Thank you!

* Luís Lima pt.luis.lima2006@gmail.com
* Guilherme Coutinho up202407040@g.uporto.pt
* José Pacheco josemiguelpacheco040806@gmail.com
* Gabriela Felgueiras gabriela.abreu.felgueiras@gmail.com
* Vasco Castanheira vasco.castanheira@gmail.com
---
## Business Modelling
<!-- 
Business modeling in software development involves defining the product's vision, understanding market needs, aligning features with user expectations, and setting the groundwork for strategic planning and execution. -->


### **Product Vision**

To empower people to reach their goals by turning individual habits into a friendly and sustainable competition.
<!-- 
Start by defining a clear and concise product vision for your app, to help members of the team, contributors, and users into focusing their often disparate views into a concise, visual, and short textual form. 

The vision should provide a "high concept" of the product for marketers, developers, and managers.

A product vision describes the essential of the product and sets the direction to where a product is headed, and what the product will deliver in the future. 

**We favor a catchy and concise statement, ideally one sentence.**

We suggest you use the product vision template described in the following link:
* [How To Create A Convincing Product Vision To Guide Your Team, by uxstudioteam.com](https://uxstudioteam.com/ux-blog/product-vision/)

To learn more about how to write a good product vision, please read:
* [Vision, by scrumbook.org](http://scrumbook.org/value-stream/vision.html)
* [Product Management: Product Vision, by ProductPlan](https://www.productplan.com/glossary/product-vision/)
* [20 Inspiring Vision Statement Examples (2019 Updated), by lifehack.org](https://www.lifehack.org/articles/work/20-sample-vision-statement-for-the-new-startup.html)
-->

### **Features and Assumptions**

**High-Level Features**

- **Thematic Circles:** Ability to join specialized groups based on specific interests or habits (e.g., Fitness, Sustainability, Photography, etc).

- **The Power of 10 (Slot System):** A hard limit of 10 active group memberships per user to ensure focus and high-quality engagement.

- **Proof-of-Action Submissions:** An interface for users to upload photo evidence of completed tasks.

- **Community Validation Engine:** A peer-review system where group members vote to approve or reject a task submission based on the photo provided.

- **Gamified Leaderboards:** A ranking within each Circle based on validated task completion and accumulated points.

- **Social Identity (Profiles):** Public-facing profiles showcasing a user’s current Circles, friends, etc.

**Assumptions and Dependencies**
- **User Integrity:** We assume the community-driven validation (voting) is enough to detect "fakes" and that users will act as honest moderators for their peers.

- **Storage Requirements:** The app assumes access to reliable cloud storage (e.g., Firebase) to handle a high volume of "Proof" images or the leaderboar's and user's information.

- **Smartphone Hardware:** We assume users have access to a functional camera and a stable internet connection for real-time photo uploads and task completion.

<!-- 
Indicate an  initial/tentative list of high-level features - high-level capabilities or desired services of the system that are necessary to deliver benefits to the users.
 - Feature XPTO - a few words to briefly describe the feature
 - Feature ABCD - ...
...

Optionally, indicate an initial/tentative list of assumptions that you are doing about the app and dependencies of the app to other systems.
-->

## Requirements

### User Stories

The **_CircleUp_** backlog is structured into four core functional areas designed to facilitate a seamless transition from individual intent to community-verified action:

- **Identity & Access Management:** Users can create and manage unique accounts, log in securely, and maintain a personal profile that aggregates their total points and active group memberships.

- **Social Connectivity:** This includes the ability to search for other users by username and view peer profiles, allowing users to inspect the "proof of action" gallery and achievements of their friends and competitors.

- **Circle Management & Navigation:** A centralized Home Dashboard provides a snapshot of daily priorities, while the Group Creation/Join feature allows users to form or enter themed "Circles" (limited to 10) to start localized and private competitions.

- **The Accountability Loop:** This includes the Group Detail Page for tracking collective progress, and the Task Submission & Validation system, where users upload photo evidence of completed goals for peer review and point allocation.
<!-- 
In this section you should describe all kinds of requirements for your module: functional and non-functional requirements.

For LEIC-ES-2025-26, the requirements will be gathered and documented as user stories. 

Please add in this section a concise summary of all the user stories (not each user story!).

**User stories as GitHub Project Items**
The user stories themselves should be created and described as items in your GitHub Project with the label "user story". 

A user story is a description of a desired functionality told from the perspective of the user or customer. A starting template for the description of a user story is *As a < user role >, I want < goal > so that < reason >.*

Name the item with either the full user story or a shorter name (recommended). In the “comments” field, add relevant notes, mockup images, and acceptance test scenarios, linking to the acceptance tests when available, and finally estimate value and effort.

**INVEST in good user stories**. 
You may add more details after, but the shorter and complete, the better. In order to decide if the user story is good, please follow the [INVEST guidelines](https://xp123.com/articles/invest-in-good-stories-and-smart-tasks/).

**User interface mockups**.
After the user story text, you should add a draft of the corresponding user interfaces, a simple mockup or draft, if applicable.

**Acceptance tests**.
For each user story you should write also the acceptance tests (textually in [Gherkin](https://cucumber.io/docs/gherkin/reference/)), i.e., a description of scenarios (situations) that will help to confirm that the system satisfies the requirements addressed by the user story.

**Value and effort**.
At the end, it is good to add a rough indication of the value of the user story to the customers (e.g. [MoSCoW](https://en.wikipedia.org/wiki/MoSCoW_method) method) and the team should add an estimation of the effort to implement it using points in a kind-of-a Fibonnacci scale (1,2,3,5,8,13,20,40, no idea).

-->

### Domain model

<!-- 
To better understand the context of the software system, it is useful to have a simple UML class diagram with all and only the key concepts (names, attributes) and relationships involved of the problem domain addressed by your app. 
Also provide a short textual description of each concept (domain class). 

Example:
 <p align="center" justify="center">
  <img src="https://github.com/FEUP-LEIC-ES-2022-23/templates/blob/main/images/DomainModel.png"/>
</p>
-->

<img width="1633" height="1315" alt="Domain Model" src="https://github.com/user-attachments/assets/38581e15-66f1-414e-83c9-b781abac8d9a" />


**User:** Represents a platform participant with authentication and scoring data. A user has credentials (username, email, password) and accumulates total points. A user can author submissions, validate others’ submissions, and belong to a groups.

**Group:** Represents a collection of users organized under a common identity. A group has a name, description, and theme. It owns multiple tasks and has an associated leaderboard. Users may belong to at most 10 groups.

**Task:** Defines a challenge or activity within a group. Each task has a title, objective, and a reward (points). Tasks belong to exactly one group and can have multiple submissions from users.

**Submission:** Represents a user’s attempt to complete a task. It includes proof (e.g., image), a timestamp, and a status (pending, approved, rejected). Each submission is authored by one user and belongs to one task. It can receive multiple validation votes.

**ValidationVote:** Represents a validation decision on a submission. A vote is either valid or invalid. It is cast by a user (validator) on a submission, with the constraint that the validator cannot be the submission’s author.

**Leaderboard:** Represents the ranking system for a group. Each group has exactly one leaderboard, which aggregates ranking entries for users based on their performance.

**LeaderboardEntry:** Represents an individual ranking record within a leaderboard. It stores a user’s position and points. Each entry is associated with one leaderboard and corresponds to a user.


## Architecture and Design
<!--
The architecture of a software system encompasses the set of key decisions about its organization. 

A well written architecture document is brief and reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the components of the project and their interrelations. You should describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.
-->

### Logical architecture

The system is organised into three layers: **Screens** (UI), **Services** (business logic), and **Models** (data structures bridging Firestore documents and the app). Screens use Services; Services communicate with Firebase and use Models. No screen accesses data directly.

- **Screens:** Home, Group, Challenge, Vote, Profile  
- **Services:** User, Group, Submission, Scoring  
- **Models:** User, Group, Challenge, Submission, Vote, Theme  

<img width="1469" height="834" alt="package" src="https://github.com/user-attachments/assets/45250416-f43e-48cd-90b9-251d602e43da" />



### Physical architecture

The app runs as a Flutter application on the user's smartphone. There is no custom server — all backend is provided by Firebase on Google Cloud. The Flutter app communicates with Firebase exclusively through the bundled Firebase SDK over HTTPS.

| Node | Role |
|---|---|
| Flutter App | Client, runs on device |
| Firebase Auth | Authentication & session tokens |
| Cloud Firestore | Main database (users, groups, challenges, submissions, votes) |
| Cloud Storage | Stores photo proof uploads |
| Cloud Functions | Triggered on vote events; updates scores and sends notifications |
| FCM | Delivers push notifications to device |

<img width="756" height="686" alt="deploymentº" src="https://github.com/user-attachments/assets/264de3bc-255f-4505-a56a-acd68292b7c4" />



### Functional prototype
<!--
To help on validating all the architectural, design and technological decisions made, we usually implement a functional prototype, a thin vertical slice of the system integrating as much technologies as we can.

In this subsection please describe which feature, or part of it, you have implemented, and how, together with a snapshot of the user interface, if applicable.

At this phase, instead of a complete user story, you can simply implement a small part of a feature that demonstrates thay you can use the technology, for example, show a screen with the app credits (name and authors).
-->

## Project management
<!--
Software project management is the art and science of planning and leading software projects, in which they are planned, implemented, monitored and controlled.

In the context of ESOF, we recommend each team to adopt a set of project management practices and tools capable of registering tasks, assigning tasks to team members, adding estimations to tasks, monitor tasks progress, and therefore being able to track their projects.

Common practices of managing agile software development with Scrum are: backlog management, release management, estimation, Sprint planning, Sprint development, acceptance tests, and Sprint retrospectives.

You can find below information and references related with the project management: 

* Backlog management: Product backlog and Sprint backlog in a [Github Projects board](https://github.com/orgs/FEUP-LEIC-ES-2023-24/projects/64);
* Release management: [v0](#), v1, v2, v3, ...;
* Sprint planning and retrospectives: 
  * plans: screenshots of Github Projects board at begin and end of each Sprint;
  * retrospectives: meeting notes in a document in the repository, addressing the following questions:
    * Did well: things we did well and should continue;
    * Do differently: things we should do differently and how;
    * Puzzles: things we don’t know yet if they are right or wrong;
    * list of a few improvements to implement next Sprint;

-->

### Sprint 0

TEST CHANGE FOR GIT ACTION

### Sprint 1

### Sprint 2

### Sprint 3

### Sprint 4

### Final Release
