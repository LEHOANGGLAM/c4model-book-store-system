workspace {
    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "Public User, Unauthenticated User" "PublicUser"
        authorizedUser = person "Authorized User" "Authorized User, authenticated user" "AuthorizedUser"

        # Software System
        # <variable> = softwareSystem <name> <description> <tag>
        bookStoreSystem = softwareSystem "Books Store System" "Allows users to interact with book records" "Target System" {
        #     # Level 2: Container
            # <variable> = softwareSystem <name> <description> <tag>
            # app = group "Application"{
            searchWebAPI = container "Search Web API" "Allows only authorized users searching books records via HTTPs handlers" "Golang" "Web API"
            adminWebAPI = container "Admin Web API" "" "Golang" "Web API"{
                # Level 3: Component
                serviceBook = component "Service Book" "" ""
                serviceAuthorizer = component "Service Authorization" "" ""
                eventPublisher = component "EventPublisher" "" ""
            }
            publicWebAPI = container "Public Web API" "" "Golang" "Web API"
            bookKafkaSystem = container "Book Kafka System" "" "Apache Kafka 3.0"
            elasticSearchEventConsumer = container "Elastic Search Events Consumer" "" "Golang"
            searchDatabase = container "Search Database" "" "Oracle Database Schema" "Database"
            readWriteRelationalDatabase = container "Read/Write Relational Database" "" "Oracle Database Schema" "Database"
            readerCache = container "Reader Cache" "" "Oracle Database Schema" "Database"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "" "Oracle Database Schema" "Database"
        }
        
        # External Software Systems
        authorizationSystem = softwareSystem "Authorization System" "The internal Microsoft Exchange e-mail system." "External System"
        publisherSystem = softwareSystem "Publisher System" "Stores all of the core banking information about customers, accounts, transactions, etc." "External System"

        # # Relationship between People and Software Systems
        publicUser -> bookStoreSystem "Read books"
        authorizedUser -> bookStoreSystem "Read books"
        bookStoreSystem -> authorizationSystem "Access authorization details"
        bookStoreSystem -> publisherSystem "Access books details"

        # Relationship between Containers
        searchWebAPI -> searchDatabase "reads data"
        adminWebAPI -> bookKafkaSystem ""
        adminWebAPI -> readWriteRelationalDatabase "Read and Write data"
        
        publicWebAPI -> readerCache "Reads/Writes data"
        publicWebAPI -> readWriteRelationalDatabase "Reads/Writes data"

        elasticSearchEventConsumer -> searchDatabase 
        elasticSearchEventConsumer -> bookKafkaSystem 
       
        publisherRecurrentUpdater -> adminWebAPI "Write details"

        # Relationship between Containers and External System
        searchWebAPI -> authorizationSystem "Authorizes"
        adminWebAPI -> authorizationSystem "Authorizes"
        publisherRecurrentUpdater -> publisherSystem ""
        publisherSystem -> publisherRecurrentUpdater ""

        authorizedUser -> searchWebAPI "searching books records via HTTPs handlers"
        authorizedUser -> adminWebAPI "call API"
        publicUser -> publicWebAPI "Call API"

        # Relationship between Components
        serviceBook -> serviceAuthorizer ""
        serviceBook -> eventPublisher 

        # # Relationship between Components and Other Containers
        serviceBook -> readWriteRelationalDatabase "Reads/Writes data"
        serviceAuthorizer -> authorizationSystem
        eventPublisher -> bookKafkaSystem

        authorizedUser -> serviceBook ""
        publisherRecurrentUpdater -> serviceBook "Writes"

        # # Deployment for Dev Env
        # deploymentEnvironment "Development" {
        #     deploymentNode "Developer Laptop" "" "Microsoft Windows 10 or Apple macOS" {
        #         deploymentNode "Web Browser" "" "Chrome, Firefox, Safari, or Edge" {
        #             containerInstance adminWebAPI
        #         }
        #         # deploymentNode "Docker Container - Web Server" "" "Docker" {
        #         #     deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
        #         #         containerInstance webApp
        #         #         containerInstance apiApp
        #         #     }
        #         # }
        #         # deploymentNode "Docker Container - Database Server" "" "Docker" {
        #         #     deploymentNode "Database Server" "" "Oracle 12c" {
        #         #         containerInstance database
        #         #     }
        #         # }
        #     }
        # }
    }

    views {
        # Level 1
        systemContext bookStoreSystem "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout
        }
        # Level 2
        container bookStoreSystem "Containers" {
            include *
            autoLayout lr
        }
        component adminWebAPI "Components" {
            include *
            autoLayout
        }

        # deployment <software-system> <environment> <key> <description>
        deployment bookStoreSystem "Development" "Dep-002-DEV" "Environment for Developer" {
            include *           
            autoLayout
        }

        styles {
            # element <tag> {}
            element "PublicUser"{
                background 	#696969
                color #ffffff
                fontSize 22
                shape Person
            }
            element "AuthorizedUser"  {
                background 	#696969
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }

}