# This file loads your app and all your tasks when running 'lucky'
#
# Run 'lucky --help' to see all available tasks.
#
# Learn to create your own tasks:
# https://luckyframework.org/guides/command-line-tasks/custom-tasks

# See `LuckyEnv#task?`
ENV["LUCKY_TASK"] = "true"
require "avram"
# Load Lucky and the app (actions, models, etc.)
require "./src/lucky_search"
require "./spec/setup/**"
require "./spec/support/app_database"
require "./spec/support/base_model"
require "./spec/support/database"

#require "./spec/support/models_spec"
#require "./spec/support/operations_spec"
require "lucky_task"

# You can add your own tasks here in the ./tasks folder
require "./tasks/**"

# Load migrations
require "./db/migrations/**"

# Load Lucky tasks (dev, routes, etc.)
#require "lucky/tasks/**"

LuckyTask::Runner.run
