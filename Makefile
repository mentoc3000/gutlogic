
PROJECT_NAME ?= gut_ai
ENV ?= dev

AWS_CF_BUCKET_NAME ?= cf-templates-ingot-us-east-1
AWS_STACK_NAME ?= $(PROJECT_NAME)-stack-$(ENV)
AWS_REGION ?= us-east-1

CF_TEMPLATE = gut_ai_stack.yaml
GRAPHQL_SCHEMA_FILE = schema.graphql
FILE_PACKAGE = package.yaml

package:
	@ aws cloudformation package \
		--template-file $(CF_TEMPLATE) \
		--s3-bucket $(AWS_CF_BUCKET_NAME) \
		--region $(AWS_REGION) \
		--output-template-file $(FILE_PACKAGE)

deploy:
	@ aws cloudformation deploy \
		--template-file $(FILE_PACKAGE) \
		--region $(AWS_REGION) \
		--capabilities CAPABILITY_IAM \
		--stack-name $(AWS_STACK_NAME) \
		--force-upload \
		--parameter-overrides \
			ParamProjectName=$(PROJECT_NAME) \
			ParamSchema="$(SCHEMA)" \
			ParamKeyExpiration=$(EXPIRATION) \
			ParamENV=$(ENV)

describe:
	@ aws cloudformation describe-stacks \
			--region $(AWS_REGION) \
			--stack-name $(AWS_STACK_NAME)

outputs:
	@ make describe \
		| jq -r '.Stacks[0].Outputs'
