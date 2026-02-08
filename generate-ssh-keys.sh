# Configuration
KEY_DIR="$HOME/.ssh"
GITHUB_KEY="$KEY_DIR/id_ed25519_github"
VPS_KEY="$KEY_DIR/id_ed25519_vps"
EMAIL="maciejgarncarski@protonmail.com"

# Create .ssh directory if it doesn't exist
mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

echo "--- Generating GitHub SSH Key ---"
# -t specifies type (ed25519 is modern/secure)
# -C adds a comment (your email)
# -f specifies the filename
ssh-keygen -t ed25519 -C "$EMAIL" -f "$GITHUB_KEY" -N ""

echo "--- Generating VPS SSH Key ---"
# Generating without a comment/email
ssh-keygen -t ed25519 -f "$VPS_KEY" -N ""

echo "--- Current Keys in $KEY_DIR ---"
ls -l "$KEY_DIR/id_ed25519_*"

echo "--- Done! ---"
echo "Your GitHub Public Key (copy this to GitHub):"
cat "${GITHUB_KEY}.pub"