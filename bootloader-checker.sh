#!/bin/bash
# bootloader-checker.sh -- Audit bootloader security state via fastboot
# Usage: ./bootloader-checker.sh
set -e
BOLD='[1m'; GREEN='[0;32m'; RED='[0;31m'; YELLOW='[1;33m'; NC='[0m'

echo -e "
${BOLD}🔒 Bootloader Security Checker${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if in fastboot
if ! fastboot devices 2>/dev/null | grep -q "fastboot"; then
    echo -e "${RED}Device not in fastboot mode. Reboot with:${NC}"
    echo "  adb reboot bootloader"
    exit 1
fi

PRODUCT=$(fastboot getvar product 2>&1 | grep -oP '(?<=product: )\S+')
UNLOCKED=$(fastboot getvar unlocked 2>&1 | grep -oP '(?<=unlocked: )\S+' || echo "unknown")
BOOTLOADER=$(fastboot getvar bootloader 2>&1 | grep -oP '(?<=bootloader: )\S+')
AVB=$(fastboot getvar secure 2>&1 | grep -oP '(?<=secure: )\S+' || echo "unknown")

echo "Device:      $PRODUCT"
echo "Bootloader:  ${BOOTLOADER:-unknown}"
echo "Unlocked:    $UNLOCKED"
echo "Verified Boot: $AVB"
echo ""

# Checks
ok=0; warn=0

if [[ "$UNLOCKED" == "no" ]]; then
    echo -e "${GREEN}✓${NC} Bootloader locked (secure)"
    ((ok++))
else
    echo -e "${YELLOW}⚠ ${NC}  Bootloader unlocked (less secure)"
    ((warn++))
fi

if [[ "$AVB" == "yes" ]]; then
    echo -e "${GREEN}✓${NC} Android Verified Boot enabled"
    ((ok++))
else
    echo -e "${YELLOW}⚠ ${NC}  Verified Boot disabled or unknown"
    ((warn++))
fi

# Check if can flash vbmeta (indicates security posture)
echo ""
echo "Flashing capabilities:"
echo -e "  ${YELLOW}Note:${NC} In locked bootloader, custom images rejected"
echo -e "  ${YELLOW}Note:${NC} --disable-verity bypasses integrity checks"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Checks passed: $ok${NC}   ${YELLOW}⚠  Warnings: $warn${NC}"

if [[ $warn -eq 0 ]]; then
    echo -e "
${GREEN}Device is properly secured.${NC}"
else
    echo -e "
${YELLOW}Consider locking bootloader for production security.${NC}"
    echo "  fastboot flashing lock"
fi
