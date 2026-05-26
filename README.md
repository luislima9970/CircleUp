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

## Setup The Environment

- **In order to run the project you should have [Flutter SDK](https://flutter.dev/) and [Dart SDK](https://dart.dev/) installed**
- **It is also advised to have an editor such as [VSCode](https://code.visualstudio.com/) or [AndroidStudio](https://developer.android.com/studio)**
- **After that you need to have a mobile phone emulator or one connected to your computer**
- **If you have everything ready, just open the emulator and run the following in your console:**

    - `flutter pub get`

        `flutter run`

- **Everything should be up and running smoothly!**

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

<img width="1138" height="1435" alt="Domain Model" src="https://github.com/user-attachments/assets/5b5d31c4-fd30-44a7-a78f-c0457d66a338" />




**User:** Represents a platform participant with authentication and scoring data. A user has credentials (username, email, password), and other profile elements such as a profile picture and phrase. A user can author submissions, validate others’ submissions, and belong to a groups.

**Group:** Represents a collection of users organized under a common identity. A group has a name, description, and theme and owns its members and multiple tasks.

**Task:** Defines a challenge or activity within a group. Each task has a title, objective, and a reward (points). Tasks belong to exactly one group and can have multiple submissions from users.

**Submission:** Represents a user’s attempt to complete a task. It includes proof (image), a timestamp, and a status (pending, approved, rejected). Each submission is authored by one user and belongs to one task. It can receive multiple validation votes.

**ValidationVote:** Represents a validation decision on a submission. A vote is either valid or invalid. It is cast by a user (validator) on a submission, with the constraint that the validator cannot be the submission’s author.

**Member:** Represents an individual user's statistics within a group. It stores a user’s position and points. Each entry is associated with one group and corresponds to a user.

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
The system is organised into three layers: **Screens** (UI), **Services** (business logic), and **Models** (data structures bridging Firestore documents and the app). Screens use Services; Services communicate with Firebase and use Models. No screen accesses data directly.

- **Screens:** Home, Group, Challenge, Vote, Profile  
- **Services:** User, Group, Submission, Scoring  
- **Models:** User, Group, Challenge, Submission, Vote, Theme  

<img width="1469" height="834" alt="package" src="https://github.com/user-attachments/assets/45250416-f43e-48cd-90b9-251d602e43da" />

Currently, our architecture doesn't reflect this diagram as we have been using the services directly to access data. We will refactor our code to use models in the next sprint so we decided it's doesnt make sense to remove them from the diagram now as they will be implemented later.

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

- **Prototype Implementation Bugs**

> There is just one current bug in the prototype, that is when the same username is opened in two devices, usually the points add up and it is almost like they got duplicated.

> When implementing firebase, we had to make changes to `user_service.dart`, and actually creating an interface and a mock for this class, because we do not want the integration tests to use firebase itself. If we did not make this changes, the test would not run correctly.

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

- **Bugs**

  **Firebase Integration Issues**

  During the implementation of user registration in the `register_screen.dart`, we encountered a Firebase Authentication error when attempting to create a new user account. The error message was: `[firebase_auth/unknown] An internal error has occurred. [ CONFIGURATION_NOT_FOUND ]`.

  This error is related to reCAPTCHA configuration in Firebase. Firebase requires a SHA-1 certificate fingerprint for Android apps to enable authentication features like email/password sign-up. Without the correct SHA-1, Firebase cannot verify the app's authenticity, leading to the CONFIGURATION_NOT_FOUND error.

  This issue needed to be solved by the one who created the Firebase Database since no ohter element had the permissions to do it.

  **Root Cause:**
  - The debug keystore SHA-1 was not added to the Firebase project settings.
  - Firebase uses this SHA-1 to configure reCAPTCHA and other security features for Android apps.

  **Solution:**
  - Retrieved the SHA-1 from the Android debug keystore using the command: `keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android`.
  - Added the SHA-1 fingerprint to the Firebase Console under Project Settings > General > Your apps > Android app > Certificates.
  - Downloaded the updated `google-services.json` and replaced the existing file in `android/app/`.
  - Ran `flutter clean`, `flutter pub get`, and `flutter run` to rebuild the app with the new configuration.

  After implementing this fix, the user registration functionality worked correctly, allowing users to create accounts and store their data in Firebase Auth and Firestore.


- **Homepage**

  Currently, the only implemented funcionality in the homepage is the `Create Group` button. The other UI elements are just mocks that don't do anything. They are there to show how the UI is going to look like and their functionality will be implemented in future sprints.

- **Sprint planning and retrospectives:**  
  * **Plans:** All planned tasks were completed.  
  ![alt text](assets/Plan-Sprint1.png)  

  * **Retrospectives:** Meeting notes were recorded in a document in the repository, addressing the following questions:  
    - **Did well:** The workflow was smooth and effective. Everything was completed on time and without unresolved bugs.  
    - **Do differently:** The main aspect to change is to make each task more modular, and each person should only work on their assigned task. In Sprint 1, some people worked on parts that did not belong to their tasks.  
    - **Puzzles:** The database was fully implemented, but only the user and authentication features are currently in use. Therefore, even with testing, we cannot yet confirm that everything is fully functional.  
    - **List of a few improvements to implement in the next Sprint:** Possibly allow login with a username instead of requiring an email. When a user signs up, they should be redirected directly to the Homepage and logged in automatically.

### Sprint 2

- **Welcome Page**

    The Welcome Page is the first screen shown when opening the app. It presents the CircleUP identity and gives the user two clear options: log in or create an account. Its main goal is to provide a simple and branded entry point before authentication.

- **Circles Page**

    The Circles page shows the groups where the current user is a member. If the user is not in any Circle yet, the page shows an empty state encouraging them to create or join a Circle.

- **Group Page**

    The Group Page works as the dashboard for a specific Circle. It displays the Circle name, theme, description, number of members, tasks and pending validations.

    The page also includes a members area and a tab system to switch between Tasks and Leaderboard. The Tasks tab is currently prepared with an empty state, while the Leaderboard tab already uses member data stored in Firestore, such as points and streak values.

- **Task Page**

   The Tasks Page shows the tasks that the current user has yet to complete, separated by the group the tasks belong to.

- **Joining a Group**

   When creating a group, a code will be generated and appear on the group's page to its users to share with other people. In the circles page, there is a button that takes the user to a joining page where they can input a group's code to join it.

- **Task Submission&Validation Page**

  When opening a task, a new page will be showed with the task name and description where you will be able to attach photos to prove that you have done the task however it is not still working, that will be correct in the next sprint.

- **Bugs**

  - **Task Submission&Validation Page Firebase Storage**

    The error occurs during an uploadImage. While it seems counter-intuitive to get a "Not Found" error when creating a new file, Firebase triggers this when the Bucket configuration is incorrect or the Security Rules prevent the initial handshake of the upload session.

    **Solution**: Update rules in the Firebase by creating a Firebase Storage in Firebase Console.

- **Sprint planning and retrospectives:**  
  * **Plans:** 
    - In this sprint is espected to implement the core mechanism of the app.
    
      ![alt text](assets/Plan-Sprint2.png)

    - In this sprint everything was implemented as expected.

      ![alt text](assets/Retro-Sprint2.png)
  
  * **Retrospectives:** Meeting notes were recorded in a document in the repository, addressing the following questions:  
    - **Did well:** The workflow was smooth and effective. Everything was completed on time and without unresolved bugs.
    - **Do differently:** In Sprint 2, some tasks should be done by diferent people who have acess to the Firebase.  
    - **Puzzles:** The database was fully implemented, and now the user, authentication, groups, tasks and submission features are currently in use. With testing, we can confirm that everything, is fully functional.  
    - **List of a few improvements to implement in the next Sprint:** We will be able to the our profile and others aswell. We will only be able to submit a task image once.


### Sprint 3

- **Profile Page**

    The Profile Page allows users to view their account information, including their personal details and profile description. It also includes a logout button so users can safely sign out of the application.

- **Edit Profile Page**
  
    The Edit Profile Page allows users to update their personal information, such as their username, profile phrase, profile image and password. The changes are saved in the database and reflected across the application, keeping the user's profile up to date.

- **See Other's Profile Page**

  The See Other's Profile Page allows users to view another user's public profile. It displays that user's information, including their personal details and profile description, as well as the groups they belong to.

- **Search for Users Page**

  The Search for Users Page allows users to search for other registered users by username. The search updates based on the text entered, making it easier to find and access other users' public profiles.

- **Group themes**

  Each group is assigned a theme that determines its 7 tasks — one per day of the week. The pointing system works as follows: submitting a task immediately earns the user points. As group members vote on the submission, positive votes add further points while negative votes deduct them. Casting a vote also rewards the voter with points, incentivising active participation in the validation process. All points accumulate on the group leaderboard, allowing members to compete and track their progress throughout the week.

- **Create Model**

  All code was refactored so that screens no longer access the database directly. Instead, data is first processed through model classes, which act as a structured layer between the Firestore documents and the UI. This ensures a cleaner separation of concerns, makes the codebase easier to maintain, and aligns the implementation with the planned logical architecture.

- **Bugs**

  - **Search for Users**

      The Search for Users page had a bug where it showed that there were no users in the application. Because of this, it was not possible to search for other users. This bug has been fixed, and the page now correctly shows and filters existing users.
    
    **Solutions**: The user search logic was updated so that the page correctly retrieves the existing users from Firestore. The filtering system was also adjusted so that users are displayed initially and then filtered according to the text written in the search bar.

  - **Edit Profile**

      The Edit Profile page had a bug where changes were not saved after clicking the save button. The profile information stayed the same as before. This bug has been fixed, and the updated information is now saved correctly.

    **Solutions**: The profile update logic was corrected so that the edited data is properly sent to Firestore and saved in the user document. After saving, the updated profile information is now displayed correctly.
  
  - **Profile error**

      The Profile page was displaying an all-time progress section that duplicated information already visible on the Home page. 

      **Solution:** Since the data was redundant, the fix was to remove it from the Profile page entirely, keeping a single source of truth on the Home page.

  - **Group appears after deleted**

      After deleting a group, the group was still visible in the list instead of disappearing immediately. This happened because the page was not being refreshed after the deletion. 
      
      **Solution:** The fix was to redirect the user after deleting, which forces a full page reload and clears the stale entry from the list.

  - **Join not redirecting to group**

      After joining a group using an invite code, the user was not being taken to the corresponding group page. 
      
      **Solution:** The fix was to add a redirect to the group that generated that code, so the user lands directly on the group page after joining.

- **Sprint planning and retrospectives:**  
  * **Plans:** 
    - In this sprint is espected to implement the profile, tasks&points mechanism of the app and refactor the code so the database info is stored in models.
    
      ![alt text](assets/Plan-Sprint3.png)

    - In this sprint everything was implemented as expected.

      ![alt text](assets/Retro-Sprint3_1.png)
      ![alt text](assets/Retro-Sprint3_2.png)
  
  * **Retrospectives:** Meeting notes were recorded in a document in the repository, addressing the following questions:  
    - **Did well:** The workflow was smooth and effective. Everything was completed on time and without unresolved bugs.
    - **Do differently:** In Sprint 3, everything worked perfectly, however some work was dependent on other people which caused some delay.  
    - **Puzzles:** The profile was fully implemented, and now the user can see his/her profile, as well as others. The pointing system is also working perfectly. With testing, we can confirm that everything, is fully functional.  
    - **List of a few improvements to implement if we had a next Sprint:** We will be able to implement a groupchat for each group, cosmetics for the profile and the user would login instantly when opening the app without login.

### Final Release
