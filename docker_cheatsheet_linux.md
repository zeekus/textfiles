
# Docker Cheat Sheet for Linux

## Installation and Setup
1. **Install Docker** (if not already installed):
   ```bash
   sudo apt-get update
   sudo apt-get install docker.io
   ```

2. **Start Docker service**:
   ```bash
   sudo systemctl start docker
   ```

3. **Enable Docker to start on boot**:
   ```bash
   sudo systemctl enable docker
   ```

4. **Add your user to the Docker group** (to run Docker without `sudo`):
   ```bash
   sudo usermod -aG docker $USER
   ```

5. **Restart the Docker service** (after adding user to the group):
   ```bash
   sudo systemctl restart docker
   ```

## Creating and Managing Networks
1. **Create a custom bridge network**:
   ```bash
   docker network create my_custom_bridge --driver bridge
   ```
   - User-defined bridge networks allow automatic DNS resolution between containers, enhancing inter-container communication.

## Running Containers
1. **Run a container interactively**:
   ```bash
   docker run -it ghcr.io/spack/tutorial:hpcic24
   ```

## Starting and Executing Commands in Containers
1. **From a cold start, start a stopped container**:
   ```bash
   docker start <container_id>
   ```
2. **Execute a command inside a running container**:
   ```bash
   docker exec -it <container_id> bash
   ```

## Stopping and Removing Containers
1. **Stop a running container**:
   ```bash
   docker container stop <container_id>
   ```
2. **Remove a stopped container**:
   ```bash
   docker container rm <container_id>
   ```

## Example Workflow with Container ID `7d27aa970c90`
- **Start the stopped container**:
  ```bash
  docker start 7d27aa970c90
  ```
- **Execute a bash shell inside the running container**:
  ```bash
  docker exec -it 7d27aa970c90 bash
  ```
- **To clean up, stop the running container**:
  ```bash
  docker container stop 7d27aa970c90
  ```
- **Remove the stopped container**:
  ```bash
  docker container rm 7d27aa970c90
  ```

## Dockerfile Management

### Dockerfile Example (`DockerF.yaml`)
- Create a `Dockerfile` with your desired configuration.

### Build an Image from a Dockerfile
1. **Build an image using a Dockerfile**:
   ```bash
   docker build -t <myimage> -f <Dockerfile> . > build.log 2>&1
   ```
   
### Run an Image 
1. **Run a built image** (example command):
    ```bash
    docker run <myimage>
    ```

## Image Management

### List Images 
1. **List all images**:
    ```bash
    docker images ls
    ```

### Stop an Image 
1. **Stop a running image/container**:
    ```bash
    docker container stop <container_id>
    ```

### View Logs 
1. **See the logs of a specific image/container**:
    ```bash
    docker logs <container_id>
    ```

### Remove an Image 
1. **Remove a specific image/container forcefully**:
    ```bash
    docker image rm <image_id> --force
    ```

### Clear Data from System 
1. **Prune unused data (containers, images, networks)**:
    ```bash
    docker system prune -a
    ```

## Additional Useful Commands

1. **List all running containers**:
   ```bash
   docker ps
   ```
2. **List all containers (including stopped ones)**:
   ```bash
   docker ps -a
   ```
3. **Inspect a container's details**:
   ```bash
   docker inspect <container_id>
   ```

## Networking Commands 
1. **Connect a running container to an existing network**:
    ```bash
    docker network connect my_custom_bridge <container_id>
    ```
2. **Disconnect a running container from a network**:
    ```bash
    docker network disconnect my_custom_bridge <container_id>
    ```

## Cleaning Up Resources 
1. **Remove unused networks**:
    ```bash
    docker network prune
    ```
2. **Remove all stopped containers**:
    ```bash
    docker container prune
    ```

## Tips for Custom Networks 
- When creating custom networks, you can specify additional options such as subnet and gateway:
  ```bash
  docker network create --driver bridge --subnet 192.168.10.0/23 --gateway 192.168.10.1 my_custom_bridge
  ```
- This allows better control over IP addressing and routing between containers.

By following this cheat sheet, you should be well-equipped to manage Docker containers, images, and networks effectively on your Linux system!
