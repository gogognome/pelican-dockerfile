# Pelican Dockerfile

A base docker setup that inherits Python 3 and loads a bunch of deps. It runs Pelican in autoload mode for dev.

This is an easy to use image to setup a Pelican static website.
This image will run the Pelican devserver, which means it will watch for changes in the content and theme files.

Also a volume has been added so you can simply map to an existing Pelican directory and the container will update the output.

Some sane requirements have been pre-built into the image.

## Build the docker image

The image is not available (yet) in the Docker hub. You can build it yourself using the following command:

```shell
docker build -t gogognome/pelican:latest -t gogognome/pelican:v1.0 .
```

## Using on a MAC or in Windows Subsystem for Linux

### Creating a new site 

To create a new directory to be used as a site: 

  ```shell
  docker run -it --rm -v $(pwd):/srv/pelican gogognome/pelican pelican-quickstart -p my-site
  ```

This will create a subdirecotry from the local directory `$(pwd)` and provision it based on how you answered the questions. 

### Running as a development server

There are two ways to run this. We are using `--name` option to make things easier later :

1. As a always running container - so the output will stream to the screen

  ```shell
  cd my-site    # Go to the directory. You should also start another console or editor. 
  docker run --rm -v $(pwd):/srv/pelican --name pelican-dev -p 8000:8000 gogognome/pelican start
  ```

2. as a daemon, using docker to push it to the background.

  ```shell
  cd my-site
  docker run --rm -v $(pwd):/srv/pelican -d --name pelican-dev -p 8000:8000 gogognome/pelican start
  ```

In both cases It takes 2-3 minutes for the first time. The web server will run locally on port 8000. 

### Viewing logs 

The logs are viewable as output whne running directly, and when the container runs as a background task (the -d) 
you can view the logs using :

```shell
docker logs -f pelican-dev
```

In both cases, any changes to the files will cause the output to be regenreated.


### Generating the website for publication to the actual webserver

  ```shell
  cd my-site
  docker run --rm -v $(pwd):/srv/pelican --name pelican-dev gogognome/pelican generate
  ```

## Stopping the container

To stop the container, since we named it, you can stop it with 

```shell
docker stop pelican-dev
```

## License

[BSD 2-Clause license](http://opensource.org/licenses/bsd-license.php)
