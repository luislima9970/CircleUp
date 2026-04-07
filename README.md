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

<img width="1633" height="1315" alt="Domain Model" src="https://github.com/user-attachments/assets/38581e15-66f1-414e-83c9-b781abac8d9a" />


**User:** Represents a platform participant with authentication and scoring data. A user has credentials (username, email, password) and accumulates total points. A user can author submissions, validate others’ submissions, and belong to a groups.

**Group:** Represents a collection of users organized under a common identity. A group has a name, description, and theme. It owns multiple tasks and has an associated leaderboard. Users may belong to at most 10 groups.

**Task:** Defines a challenge or activity within a group. Each task has a title, objective, and a reward (points). Tasks belong to exactly one group and can have multiple submissions from users.

**Submission:** Represents a user’s attempt to complete a task. It includes proof (e.g., image), a timestamp, and a status (pending, approved, rejected). Each submission is authored by one user and belongs to one task. It can receive multiple validation votes.

**ValidationVote:** Represents a validation decision on a submission. A vote is either valid or invalid. It is cast by a user (validator) on a submission, with the constraint that the validator cannot be the submission’s author.

**Leaderboard:** Represents the ranking system for a group. Each group has exactly one leaderboard, which aggregates ranking entries for users based on their performance.

**LeaderboardEntry:** Represents an individual ranking record within a leaderboard. It stores a user’s position and points. Each entry is associated with one leaderboard and corresponds to a user.

<!-- 
To better understand the context of the software system, it is useful to have a simple UML class diagram with all and only the key concepts (names, attributes) and relationships involved of the problem domain addressed by your app. 
Also provide a short textual description of each concept (domain class). 

Example:
 <p align="center" justify="center">
  <img src="https://github.com/FEUP-LEIC-ES-2022-23/templates/blob/main/images/DomainModel.png"/>
</p>
-->


## Architecture and Design
<!--
The architecture of a software system encompasses the set of key decisions about its organization. 

A well written architecture document is brief and reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the components of the project and their interrelations. You should describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.
-->


### Logical architecture
<!--
The purpose of this subsection is to document the high-level logical structure of the code (Logical View), using a UML diagram with logical packages, without the worry of allocating to components, processes or machines.

It can be beneficial to present the system in a horizontal decomposition, defining layers and implementation concepts, such as the user interface, business logic and concepts.

Example of _UML package diagram_ showing a _logical view_ of the Eletronic Ticketing System (to be accompanied by a short description of each package):

![LogicalView](https://user-images.githubusercontent.com/9655877/160585416-b1278ad7-18d7-463c-b8c6-afa4f7ac7639.png)
-->


### Physical architecture
<!--
The goal of this subsection is to document the high-level physical structure of the software system (machines, connections, software components installed, and their dependencies) using UML deployment diagrams (Deployment View) or component diagrams (Implementation View), separate or integrated, showing the physical structure of the system.

It should describe also the technologies considered and justify the selections made. Examples of technologies relevant for ESOF are, for example, frameworks for mobile applications (such as Flutter).

Example of _UML deployment diagram_ showing a _deployment view_ of the Eletronic Ticketing System (please notice that, instead of software components, one should represent their physical/executable manifestations for deployment, called artifacts in UML; the diagram should be accompanied by a short description of each node and artifact):

![DeploymentView](https://user-images.githubusercontent.com/9655877/160592491-20e85af9-0758-4e1e-a704-0db1be3ee65d.png)
-->


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

- **Prototype Implementation Bugs**

> There is no current bug in the prototype, however, when implementing firebase, we had to make changes to `user_service.dart`, and actually creating an interface and a mock for this class, because we do not want the integration tests to use firebase itself. If we did not make this changes, the test would not run correctly.

- **Survey Analysis**

  - **Overview**

     This survey was conducted to better understand the potential acceptance of the **CircleUP** app and identify the features users value most. The questionnaire explored participants’ motivations, concerns, habits, and preferences regarding challenge-based mobile applications.

    The results provide useful guidance for defining the priorities of the app and understanding which features should be emphasized in an initial version.


  - **Personal Information**

    The survey mainly reached a younger audience, although a few older participants were also represented. Most respondents were **19 years old**, while the remaining valid ages were **20, 50, and 52**. This suggests that the concept may appeal to more than one age group, even if its strongest relevance is among young adults.

    Participants mostly heard about the app through **direct and familiar channels**, especially university and personal connections. For those who selected **Other**, the written answers were **Family** and **My daughter**, reinforcing the importance of informal networks.

  - **Questions**

    The app concept was generally **well received**. Most participants said they would use an app where friends complete challenges together, showing that the social aspect of the experience is attractive.

    **Competition** emerged as the strongest motivational factor, standing out above points, streaks, and rewards. In addition, **proof submission** was seen as highly important, showing that users value fairness and credibility when completing challenges.

    Opinions on **voting by friends** were more balanced, suggesting that this feature may require careful design to avoid concerns about unfairness. **Streaks** also received mixed reactions, which suggests they may work better as a secondary feature rather than as a core element.

    When asked about the most important feature for a first version, **easy submission** stood out clearly. The main risks identified were **boring challenges**, **unfair voting**, and **too much complexity**.


  - **User Habits / Preferences**

    Most respondents do not use similar apps very often, which means CircleUP should offer a **simple and engaging experience** in order to become part of their routines.

    What would keep users coming back most was **new challenges**, followed by **group interaction** and **rewards**. Ease of use was also rated as highly important, reinforcing that the app should feel intuitive and low-effort to use.

    Some caution also appeared regarding **proof sharing**. Many participants were unsure about sharing photos or screenshots, which highlights the importance of **privacy** and **control over shared content**. Other possible barriers included **lack of interesting challenges**, **unfair validation**, and **too much effort required**.

  - **App Topics**

    Users showed a clear preference for a **flexible experience**. Most respondents preferred having **both individual and group-based challenges**, instead of only one format.

    The **leaderboard** was seen as a strong motivational feature, reinforcing the importance of competition in the app. In contrast, **reminders and notifications** received more balanced opinions, suggesting that they should be optional or customizable rather than central to the experience.

    **Progress tracking** was also positively valued, showing that users appreciate being able to monitor their development over time. When asked about the focus of the app, most participants preferred a combination of **fitness and sustainability**, pointing to a broader and more versatile concept.

  - **Final Questions**

    The open-ended answers were limited, but they still supported the main trends identified throughout the survey.

    One respondent suggested **profile personalization**, which could help increase identity and engagement within the app. Another highlighted the **leaderboard** as an important feature for encouraging user participation.

    These answers reinforce the value of **personalization**, **motivation**, and **social interaction** within the CircleUP experience.

  - **Conclusion**

    Overall, the survey shows that the **CircleUP** concept was positively received. Users seem especially interested in the app’s **social and competitive elements**, particularly features such as leaderboards, group interaction, and challenge-based participation.

    For an initial version of the app, the main priorities should be:

    - **Easy challenge submission**
    - **Interesting and varied challenges**
    - **A fair validation system**
    - **Simple and intuitive usability**

    At the same time, concerns such as **privacy**, **unfair voting**, and **excessive complexity** should be carefully addressed to support long-term engagement.

    By focusing on **usability**, **motivation**, and **flexibility**, CircleUP can offer a more engaging and sustainable user experience.

### Sprint 1

### Sprint 2

### Sprint 3

### Sprint 4

### Final Release