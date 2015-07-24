SFTP Server
===========

# Running

Just use this command to start the container. Unbound will listen on port 53/udp.

```docker run --name sftp -v <host>:/data/incoming -d -P writl/sftp```

# Configuration
These options can be set:

- **USER**: Sets the username. (Default: "sftp", Possible Values: "<string>")
- **PASS**: Sets the password of the User (Default: "c83eDteUDT", Possible Values: "<string>")
- **GROUP_ID**: Sets GID of the user (Default: "1000", Possible Values: "<integer>")
- **USER_ID**: Sets UID of the user (Default: "1000", Possible Values: "<integer>")
