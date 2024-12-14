package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"time"

	"github.com/spf13/cobra"
	"golang.org/x/crypto/ssh"
	"golang.org/x/term"
	"gopkg.in/yaml.v3"
)

type Server struct {
	IP   string `yaml:"ip"`
	User string `yaml:"user"`
}

type ServerConfig map[string]Server

var (
	configFile = "config/config.yaml"
	servers    ServerConfig
)

func loadConfig() {
	data, err := os.ReadFile(configFile)
	if err != nil {
		log.Fatalf("Failed to load config file: %v", err)
	}
	if err := yaml.Unmarshal(data, &servers); err != nil {
		log.Fatalf("Failed to parse config file: %v", err)
	}
}

func promptPassword() string {
	fmt.Print("Enter password: ")
	bytePassword, err := term.ReadPassword(int(os.Stdin.Fd()))
	if err != nil {
		log.Fatalf("Failed to read password: %v", err)
	}
	fmt.Println()
	return string(bytePassword)
}

func connect(serverName string) {
	server, exists := servers[serverName]
	if !exists {
		fmt.Printf("Server %s not found in configuration.\n", serverName)
		return
	}

	password := promptPassword()

	config := &ssh.ClientConfig{
		User:            server.User,
		Auth:            []ssh.AuthMethod{ssh.Password(password)},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(), // For simplicity; replace with proper validation in production
		Timeout:         5 * time.Second,
	}

	address := net.JoinHostPort(server.IP, "22")
	client, err := ssh.Dial("tcp", address, config)
	if err != nil {
		log.Fatalf("Failed to connect to server %s: %v", serverName, err)
	}
	defer client.Close()

	fmt.Printf("Connected to %s (%s)\n", serverName, server.IP)

	session, err := client.NewSession()
	if err != nil {
		log.Fatalf("Failed to create SSH session: %v", err)
	}
	defer session.Close()

	session.Stdout = os.Stdout
	session.Stderr = os.Stderr
	session.Stdin = os.Stdin
	err = session.RequestPty("xterm-256color", 80, 40, ssh.TerminalModes{
		ssh.ECHO:          1,     // Enable echoing
		ssh.TTY_OP_ISPEED: 14400, // Input speed = 14.4kbaud
		ssh.TTY_OP_OSPEED: 14400, // Output speed = 14.4kbaud
	})
	if err != nil {
		log.Fatalf("Failed to set terminal mode: %v", err)
	}

	err = session.Run("bash --login -i")
	if err != nil {
		log.Fatalf("Failed to start bash shell: %v", err)
	}
}

func main() {
	loadConfig()

	var rootCmd = &cobra.Command{
		Use:   "conn",
		Short: "SSH CLI Tool",
	}

	var connectCmd = &cobra.Command{
		Use:   "connect [server]",
		Short: "Connect to a server",
		Args:  cobra.MinimumNArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			connect(args[0])
		},
	}

	var listCmd = &cobra.Command{
		Use:   "list",
		Short: "List all available servers",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("Available servers:")
			for name, server := range servers {
				fmt.Printf("- %s (IP: %s, User: %s)\n", name, server.IP, server.User)
			}
		},
	}

	rootCmd.AddCommand(connectCmd, listCmd)
	if err := rootCmd.Execute(); err != nil {
		log.Fatalf("Command execution failed: %v", err)
	}
}
