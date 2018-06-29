#!/bin/bash

bundle check || bundle update

while ! pg_isready -h one-bit-flix-database -p 5432 -q -U postgres; do
	>&2 echo "postgres is unavailable"
	sleep 1
done

>&2 echo "postgres is up"

if !(bundle exec rake db:migrate); then
  >&2 echo "=========== DATABASE DOES NOT EXIST... yet"
	bundle exec rake db:create
	>&2 echo "=========== DATABASE CREATED"
	bundle exec rake db:migrate
	>&2 echo "=========== DATABASE MIGRATED"
else
  >&2 echo "=========== DATABASE EXIST.... yay"
	bundle exec rake db:migrate
	>&2 echo "=========== DATABASE MIGRATED (already exists)"
fi

bundle exec rake db:seed
>&2 echo "=========== DATABASE SEEDED"

bundle exec rails s -p 3000 -b '0.0.0.0'
