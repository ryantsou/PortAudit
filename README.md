# PortAudit

Bash scripts for auditing open ports and active services on Linux systems.

## Installation

1. Clone this repository:
```bash
git clone https://github.com/ryantsou/PortAudit.git
```

2. Navigate to the directory:
```bash
cd PortAudit
```

3. Make the script executable:
```bash
chmod +x port-audit.sh
```

## Usage

Run the script with root privileges:

```bash
sudo ./port-audit.sh [OPTIONS]
```

## Options

- `-p, --ports` : Display only open ports
- `-s, --services` : Display only active services
- `-a, --all` : Display both open ports and active services (default)
- `-o, --output FILE` : Save output to specified file
- `-h, --help` : Display help message

## Examples

### Display all open ports and active services:
```bash
sudo ./port-audit.sh
```

### Display only open ports:
```bash
sudo ./port-audit.sh --ports
```

### Display only active services:
```bash
sudo ./port-audit.sh --services
```

### Save output to a file:
```bash
sudo ./port-audit.sh --output audit-report.txt
```

## Output

The script provides detailed information about:
- List of open TCP/UDP ports
- Associated processes and PIDs
- Active system services
- Service status and descriptions
- Listening addresses and ports

Output is formatted in a clear, readable manner with timestamps for audit tracking.

## Author

**Riantsoa RAJHONSON**
