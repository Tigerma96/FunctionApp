from setuptools import setup

setup(
    name="functionapp",
    version="1.0.0",
    install_requires=[
        "azure-storage-blob==12.23.1",
        "notion-client==2.2.1",
        "azure-functions==1.21.3",
        "opencensus-ext-azure==1.1.13",
    ],
)
