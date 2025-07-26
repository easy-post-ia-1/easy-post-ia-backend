#!/bin/bash
curl --fail "http://localhost:${API_PORT:-4000}/up" || exit 1

