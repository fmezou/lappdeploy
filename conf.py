# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = "lAppDeploy"
copyright = "2016, Frederic MEZOU"
author = "Frederic MEZOU"

version = "0.3"
# The full version, including alpha/beta/rc tags
release = '0.3.1'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.napoleon",
    "sphinx.ext.doctest",
    "sphinx.ext.intersphinx",
    "sphinx.ext.todo",
    "sphinx.ext.coverage",
    "sphinx.ext.graphviz",
    "sphinx_rtd_theme"
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['docs/_templates']

# The root document.
root_doc = 'index'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = [
    "build/",
    "README.rst"
]

# A string of reStructuredText that will be included at the end of every source
# file that is read.
rst_epilog = """
.. include:: /docs/rst-epilog.txt
"""

# sectionauthor and moduleauthor directives have to be shown in the output.
show_authors = False

# `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = True

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Theme options, see the documentation.
#  https://pypi.org/project/sphinx-rtd-theme/
html_theme_options = {
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['docs/_static']

# Links to the reST sources are not added to the pages.
html_show_sourcelink = False

# Language to be used for generating the HTML full-text search index.
html_search_language = "en"

# -- Options for Sphinx extensions ---------------------------------------------

# -- Options "sphinx.ext.autodoc",
# Documented members are sorted by member type
autodoc_member_order = "groupwise"

# -- Options "sphinx.ext.napoleon",
# Enable support for Google style docstrings.
napoleon_google_docstring = True
# Disable support for NumPy style docstrings.
napoleon_numpy_docstring = False

# -- Options "sphinx.ext.doctest",

# -- Options "sphinx.ext.intersphinx",
# Locations and names of other projects that should be linked to in this
# documentation.
# Add links to modules and objects in the Python standard library documentation.
intersphinx_mapping = {"python": ("https://docs.python.org/3", None)}

# -- Options "sphinx.ext.todo",

# -- Options "sphinx.ext.coverage",

# -- Options "sphinx.ext.graphviz",
graphviz_output_format = "svg"

# -- Options "sphinx_rtd_theme"
