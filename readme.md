# IFT2935 - Projet de fin de session
H22

## Contributors
[@jeankhoury0](https://github.com/jeankhoury0)

[@GuiPil](https://github.com/GuiPil)

[@tianpeng97](https://github.com/tianpeng97)

[@mahdimds99](https://github.com/mahdimds99)

## Tech Stack
Java, postgreSQL
## How it works

To make run the application first:

1. Initialse the database by running the script ```seed.sql```
2. Add the setings in [/config.properties](/config.properties)
>### ```Config.property```
> config.JDBC.user=postgres
> 
>config.JDBC.password=admin
>
> config.JDBC.url=jdbc:postgresql://localhost:5432/
   

*Make sure you leave no spaces in the file* 


3. Run the [project.jar](project.jar) using the command 
``` java -jar "project.jar" ```