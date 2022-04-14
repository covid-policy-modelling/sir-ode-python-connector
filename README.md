# SIR ODE (Python) model connector


This is a simple example of a model conector for an SIR model that is run to steady state.
The final size, the peak infected, and the time of the peak infected is returned, alongside the times and states of the model.

## Content

* [Prerequisites](#prerequisites)
* [Assumptions](#assumptions)
* [Process](#process)
* [Requirements for Docker images](#requirements-for-docker-images)
* [Input](#input)
* [Output](#output)
* [Updating your model](#updating-your-model)
* [Alternative integrations](#alternative-integrations)
* [Examples](#examples)

## Prerequisites

To get this framework to work you will need to have the following tooling installed in your system:

* Either:
  * [Docker Desktop](https://www.docker.com/products/docker-desktop) (only for Windows/macOS) or
  * [Docker Engine](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/engine/install/)

The document also assumes a basic knowledge of Docker, JSON & JSON Schema.
For more information on these:

* [Docker - Getting Started](https://docs.docker.com/get-started/) - Parts 1-3 & 9 are most relevant.
* [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/).
* [Docker Compose](https://docs.docker.com/compose/).
* [Ten simple rules for writing Dockerfiles for reproducible data science](https://doi.org/10.1371/journal.pcbi.1008316).
* [JSON](https://developer.mozilla.org/en-US/docs/Glossary/JSON).
* [JSON Schema](http://json-schema.org/learn/getting-started-step-by-step).

## Requirements for model connectors

* The CMD/connector must return:
  * a zero status if the simulation succeeds (e.g. with `exit`, `sys.exit()` or whatever is appropriate for your language)
  * a non-zero status if the simulation fails. A connector *may* use specific codes to indicate different types of errors, but this is not required. At present, the error codes understood by the model-runner are:
    * `10` - The connector does not support the requested region/subregion
  * If the model already returns an appropriate status, the connector can simply pass it on. Otherwise the connector code should check the model output/logs for appropriate messages.
* The container must not require any arguments in order to carry out the simulation:
  * Specify [`CMD`](https://docs.docker.com/engine/reference/builder/#cmd) (or [`ENTRYPOINT`](https://docs.docker.com/engine/reference/builder/#entrypoint)) appropriately in such a way that the container can be executed with no special arguments or other knowledge.
  * Do not specify any additional arguments in `docker-compose.yml`.
* If your model requires additional data beyond that given in the input schema, either:
  * Add it your repository and add it to the container at build-time, e.g. with [`COPY`](https://docs.docker.com/engine/reference/builder/#copy)/[`ADD`](https://docs.docker.com/engine/reference/builder/#add)
  * Download it to the container at build-time, e.g. with [`RUN wget`](https://docs.docker.com/engine/reference/builder/#run).
  * Download it in your connector code.
* At run-time,
  * Copy/store any additional input data into `/data/input/`
    * `/data/input/` will be volume mounted into the container, and will be available for download in the UI after completion (useful for audit/reproducibility purposes).
  * Copy/store any additional output data in `/data/output/`
    * `/data/output` will be volume mounted into the container, and will be available for download in the UI after completion (useful for users to explore the output of your model beyond that included in the web-ui).
* Any messages that are printed to STDOUT will not be displayed to end-users, but can be useful for debugging in the backend.
* Any additional logging should be copied/stored in `/data/log` (this will be volume mounted into the container, but will not be available for download by default).

### Input

A file with all of the required input information will be mounted into the container as *`/data/input/inputFile.json`*.

This file will contain JSON that satisfies the [`MinimalModelInput` schema](https://github.com/covid-policy-modelling/schemas/blob/main/schema/input-minimal.json).

### Output

After the simulation, your connector is expected to create the file *`/data/output/data.json`*.

This file will contain JSON that satisfies the [`MinimalModelOutput` schema](https://github.com/covid-policy-modelling/schemas/blob/main/schema/output-minimal.json).

## Updating the model

Changes to models should be made by following a similar approach to initial creation.

1. Make and test changes to your model / connector code.
1. Edit `meta.yml` with any new parameters / regions etc. if necessary
  1. Raise a PR against the `web-ui` repository, to make the same change to the `models.yml` file.
1. Tag your model connector (`git tag v<version>`, e.g. `git tag v0.0.2`) and push the tag to GitHub. Ensure the Docker image is build and published successfully.
1. Notify the maintainers of any infrastructure that deploys a specific version of your model (e.g in `web-ui/.override-staging/models.yml`)
  1. Maintainers can then follow the instructions for *Deploying updated code > model connectors* from `infrastructure/README.md` to release the model.
