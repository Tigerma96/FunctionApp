from setuptools import setup


setup(
    name="functionapp",
    version="1.0.0",
    install_requires=[
        "azure-storage-blob==12.23.1",
        "pandas==2.2.3",
        "azure-functions==1.21.3",
    ],
)
