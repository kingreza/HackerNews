
![Logo](logo.png)

# Hacker News in Workflow

![Swift](https://github.com/kingreza/HackerNews/workflows/Swift/badge.svg)

**Hacker News in Workflow** is a Hacker News client app that uses Square's [Workflow](https://github.com/square/workflow) to drive its business logic and behind the scenes architecture and Square's [Blueprint](https://github.com/square/Blueprint) and [Listable](https://github.com/kyleve/Listable) for composable and declarative UI components.


![Demo](news.gif)
![Demo](comments.gif)

# Up and running

Setting up and running the app should be fairly straight forward. The [Hacker News API](https://github.com/HackerNews/API) is read only and public so there is no need to setup token keys etc. 
 1. Clone the repository, 
 2. `pod install`
 3. Build and run 

## What's covered

This app is intended to be an example that brings Workflow, Blueprint, and Listable under one roof in an isolated, non-trivial app. It's also a good example that demonstrates: 

#### Workflow:
 - Nested workflows
 - Embedding in a navigation controller
 - Making network calls
 - Firing up multiple async Workers
 - Outputting actions from a child workflow to its parent 
 - Nontrivial state management 
 - Building out Worker specific actions
 - Displaying different screens based on a Workflow's state
 - Dependency injection within Workflow and mocking data for testing
 - Testing Workflow actions
 - Testing Workflow render passes under various states

#### Blueprint:
 - Building Workflow screens with Blueprint elements
 - A reusable AttributedTextView component
 - Composition of components 
 - Quite a few examples of components with various data and interaction funnels

#### Listable:
   - Feeding large async data that updates in multiple runs (example can be found in comments and their nested comments)
   - Ability to 'load more' as user scroll to the bottom
      Use of refresh controller
    - Building out Listable rows from Blueprint components
        

## What's left

If you're interested to expand on this example here are some ideas:
#### Easy:
 - Communicate errors back with the user. 
 -  Add snapshot tests for UI components
 -  Add tests for HackerNewsRootWorkflowTests
 -  Show a loading indicator while nested comments are loading. 

##### Medium:
  - Hacker News has different types of news articles: "**Story**, **ask**, **job**, **poll**" build article-specific row cells.
 - Add refresh for comments.

##### Harder:
  - Add the ability to fold nested comments.
  - Query the article's URL and see if it's possible to get a  description, hero image or summary through its data attributes.

