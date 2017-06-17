# Alpine TensorFlow

[![](https://images.microbadger.com/badges/image/petronetto/tensorflow-alpine.svg)](https://microbadger.com/images/petronetto/tensorflow-alpine "Get your own image badge on microbadger.com")
[![GitHub issues](https://img.shields.io/github/issues/petronetto/tensorflow-alpine.svg)](https://github.com/petronetto/tensorflow-alpine/issues)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/petronetto/tensorflow-alpine/master/License.txt)
[![Twitter](https://img.shields.io/twitter/url/https/github.com/petronetto/tensorflow-alpine.svg?style=social)](https://twitter.com/intent/tweet?text=Wow:&url=%5Bobject%20Object%5D)

## What is include
- Python 3.5
- NumPy
- SciPy
- Scikit-learn
- Pandas
- Matplotlib
- TensorFlow
- Jupyter Notebook


## Running the container
- Clone this repository: `git clone git@github.com:petronetto/tensorflow-alpine.git`

- Enter in project folder: `cd tensorflow-alpine`

- Run: `docker-composer up` and open your browser in `http://localhost:8888`

See the `Welcome.ipynb` to see the package versions.

### Enabling Warning Messages
By default the Warning Messages are disabled, if you want to enable, simply umcomment 
the `environment` section in `docker-compose.yml` file.

Enjoy :)

License: [MIT](License.txt)
