# Learn How to Learn


1. [Overview](#overview)
2. [My Learning Process](#process)
3. [Process Example](#example)

### Overview <a name="overview"></a>
Being in the tech industry for a number of years, it is no secret that we are always learning. It feels like every month I'm saying to myself, "The organization needs what? I've never done that before." This brings up the question of, do you know how you like to learn new things? Learning how to learn I think is a skill set all its own that will directly contribute to your success in technical positions.

Below are my personal opinions on how to build a good learning process that can be used throughout a person's career in the world of tech. These may not work for all individuals or in this order, but use this as a thought experiment to understand your own process to learning. 

 ## My Learning Process <a name="process"></a>

### Documentation practices
Before beginning a new learning adventure, decide how you will record what you're learning. I love to document things and understand that may come more naturally to some. Others may look at documentation as a chore to be avoided if you're not forced to partake. The fact is that documentation is crucial if you have a good understanding of how it benefits your career. How many times have you told yourself, "Geez, I wish I wrote that down 6 months ago" or "How did we do that last year?" Look at documentation as an <u>investment</u> that costs a little time now, but can be a great pay off in the future. It is also a way to solidify your experience into something you can recall in the future. You cannot expect to remember so many complex details about your experience over many years. Documentation does not mean always writing things down. A number of media avenues are available depending on what works for you.

- Process recording tools
- Record your screen as you talk your way through things
- Tools like Notion and OneNote capture different media types
- Audio recordings
- Blogging

### What do you need to learn about?
Knowing how you'll document your knowledge now leads to the next question: what do you need to learn? I like to start off with getting to know the topic I am learning about vs. just jumping in right away to build something. Here are some ideas to investigate:

- Review official documentation for what you are learning. Find out what it's called, who uses it, why it's used, etc. 
- What level of expertise will I need to achieve in order to accomplish tasks I'm being called to do?
- What are the benefits vs. trade-offs of this new thing I'm learning about?

### Quick start guides
Having a general understanding of what you are learning in your mind, the next step is getting some hands on experience. It is easy to get overwhelmed when interacting with something you've never seen before, but do not worry. 

- I like to start with official **Quick Start Guides** for things I'm learning, which typically keep things simple and approachable. 
- Start small and work on the fundamental basics first. It is easy to build on the basics.
- Running into obstacles should be expected and actually is the most <u>effective</u> part of learning.  
- Document your obstacles, all your attempts to overcome it, and what ended up being the overall fix to break through that obstacle. 


### When to ask for help
There are times when we need help in order to overcome roadblocks. 

- Work on your hands on labs in a safe environment like a local or test system. Some place where breaking things is part of the learning journey and will not negatively impact sensitive systems. 
- If you run into roadblock after roadblock, it may be you are trying something a little too difficult right away. Take a step back and try an easier project first to gain more fundamental experience before tackling advanced objectives. 
- Expect that you will run into roadblocks or obstacles. Do you best to personally investigate, research, and experiment your issues first. 
- After personally giving it a go, reach out to members of the tech community or help forums. When asking for help, try as much as possible not to ask others to solve the issue for you. Ask for help pointing you in a direction to discover the solution for yourself. As much as possible, try to put yourself in a situation where you still have to do the work to fix your issue, but may just need help pointing you in a direction. 
- Be kind and respectful to community members that offer help. 

### Capture
Now that you have gained knowledge and learned something new, circle back to your documentation. Remember to write it down oir record it somehow! After going through a bout of learning, it's easy to say to yourself, "I don't need to write this down." or "I will document it next week." 

## Process example <a name="example"></a>
Here is an example of the process at work learning about **Azure Storage Account Blob Containers**:

My boss tells me the organization wants to start using Azure Storage Accounts; mainly blob containers. I have never used Azure Storage Accounts before. I first need to find out what are Azure Storage Accounts and why they are used?

I head over to Microsoft's official documentation for [Azure Storage](https://learn.microsoft.com/en-us/azure/storage/common/storage-introduction) in general. I review the different storage Azure offers and it gives some information on why I would use some of these services vs. others. Digging into this post, I find more specific details on [Azure Storage Account Blob Containers](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction). I see that they are mainly used allowing unstructured data to be stored and accessed at a massive scale with a number of different ways to interact with the storage like HTTP REST calls, in the Azure Portal, PowerShell, a number of programming languages, etc. 

Armed with a little bit of knowledge on what they are and what they are good for, I want to build a simple Azure Storage Account and start exploring what it can do. I head over to the [Azure Storage Account Quick Start Guide](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&tabs=azure-portal) to build a Storage Account and the [Azure Storage Blob Quick Start Guide](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal) to build a blob container via different methods like the Azure Portal, PowerShell, etc. 

While exploring Azure Storage Account Blob features, I am trying to find how to accomplish certain actions. I find that Microsoft has some [Microsoft Learn](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-create-geo-redundant-storage?tabs=dotnet) pages with specific examples and a ton of [Azure Storage Account GitHub](https://github.com/MicrosoftDocs/azure-docs/tree/main/articles/storage/blobs) demonstrations and examples to review. 

Reviewing all the Microsoft documentation and examples, I find a use case that is not explained. I investigate the settings in the Azure Storage Account and do not see a configuration that looks to accomplish what I want. After some time searching, I post a couple of questions in IT communities like Discord Servers, IT forums, etc. When making a post, I make sure to clearly describe what I'm trying to do, the issue I am running into, and asking for help pointing me in the right direction where I can resume my work. The community points me to a StackOverflow post of someone that had the same issue. I make sure to thank the community members for their help and post if the help fixed my issue or not. I review that post, find a direction to investigate and start experimenting. After a few tries and some modifications, I am able to solve the issue. 

I start making some Azure Storage Account Blob Containers in my development area in my organization testing how this will integrate with my company workflows. I create documentation showing the issues I ran into, how they were solved, how to build Storage Accounts correctly for my company, who will be using these accounts and what will be stored in them, etc. 
