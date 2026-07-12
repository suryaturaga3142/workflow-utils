## Headless Vivado

Something I worked on a while back to let me run most Vivado commands without the GUI. It is a set of scripts that wrap around the Vivado Tcl shell and provide a more user-friendly interface for common tasks. It was back when I was on Windows, so I'm not sure it'll work for me now. Still, it's a good starting point for anyone looking to automate Vivado tasks without using the GUI.

The general flow of linting, simulation, synthesis, and implementation work reliably. Working with a Block Diagram is questionable. The Makefile shows an entire set of software commands in case one is working with other tools in the same project directory. I used AI's help back when I first tried this. It was a good starting point, but I think I could do better now if I were to rewrite it. I also have a few ideas for improvements, but I haven't had the time to implement them yet. Hit me up if you want to collab on this.

Surya Turaga
