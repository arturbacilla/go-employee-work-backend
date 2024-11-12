# Use the official Golang image as the base image
FROM golang:1.23-alpine

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the go.mod files
COPY ./src/go.mod ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY ./src ./

# Build the Go app
RUN go build -o main .

# Command to run the executable
CMD ["./main"]
