# tango-client-liquibase-command-utility

This action is responsible running liquibase commands

## Inputs

See the "inputs" section [here](./action.yml)

## Example usage

``` yaml
- name: Run Liquibase Command
  uses: TheAtlasTango/tango-client-liquibase-command-utility@v1.0.0
  with:
    environment: "dev"
    liquibaseCommand: "history"
    changeSetFile: "db.changelog-01.yml"
    changesetId: "location-manager-2.1"
    changesetAuthor: "Zeal"