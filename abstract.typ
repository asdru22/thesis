= Abstract
In this document I will relay the problem analysis, research and development conducted during my internship program.

The primary objective was to develop software that facilitates and streamlines the creation of projects written in the domain-specific language (DSL) of the popular videogame _Minecraft_, known as _mcfunction_.
The first section outlines the structure and key components of the DSL, establishing the foundational concepts upon which the language and its file ecosystem are built.
Next, I will highlight its main structural and syntactical flaws and how to overcome them.\
The following chapter focuses on the Java library developed during the internship, which was conceived to mitigate these issues. The library aims to simplify repetitive and verbose tasks, while also focusing on ease of access and user experience.\
By introducing features of a high-level language like Java, the library not only provides the means to eliminate the more tedious aspects of working with mcfunction, but also enables the declaration and use of multiple resources within a single file: a behavior not natively supported by Minecraft's compiler.\
A working example will then present how the library is used through the development of a project tailored to showcase its advantages compared to the traditional approach.\
Finally, a comparative analysis between the Java-based implementation and the conventional method will highlight the reduction in workload achieved through fewer lines of code and a smaller number of files.\

Throughout the development process, I had the opportunity to revisit and refine the structure of several classes. This iterative process allowed for multiple refactorings and use of various design patterns and abstraction layers to enhance the project's modularity, readability, and maintainability.
