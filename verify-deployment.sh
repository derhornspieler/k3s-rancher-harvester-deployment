#!/bin/bash
# Rancher Deployment Verification Script
# This script verifies that all components are properly deployed and accessible

set -e

NAMESPACE="rancher-mgmt"
VM_NAME="rancher-mgmt"

echo "=========================================="
echo "Rancher Deployment Verification"
echo "=========================================="
echo ""

# Check if VM exists
echo "🔍 Checking VM status..."
if kubectl get vm $VM_NAME -n $NAMESPACE &>/dev/null; then
    VM_STATUS=$(kubectl get vm $VM_NAME -n $NAMESPACE -o jsonpath='{.status.printableStatus}')
    echo "✅ VM Status: $VM_STATUS"
else
    echo "❌ VM not found"
    exit 1
fi

# Get VM IP
VM_IP=$(kubectl get vmi $VM_NAME -n $NAMESPACE -o jsonpath='{.status.interfaces[0].ipAddress}' 2>/dev/null)
if [ -z "$VM_IP" ]; then
    echo "❌ VM IP not assigned"
    exit 1
fi
echo "✅ VM IP: $VM_IP"
echo ""

# Check SSH connectivity
echo "🔍 Checking SSH connectivity..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no rocky@$VM_IP 'echo Connected' &>/dev/null; then
    echo "✅ SSH accessible"
else
    echo "❌ SSH not accessible"
    exit 1
fi
echo ""

# Check cloud-init status
echo "🔍 Checking cloud-init status..."
CLOUDINIT_STATUS=$(ssh rocky@$VM_IP 'sudo cloud-init status 2>/dev/null | grep status | awk "{print \$2}"')
echo "   Status: $CLOUDINIT_STATUS"
if [ "$CLOUDINIT_STATUS" = "done" ]; then
    echo "✅ Cloud-init completed"
else
    echo "⚠️  Cloud-init still running (status: $CLOUDINIT_STATUS)"
fi
echo ""

# Check K3s cluster
echo "🔍 Checking K3s cluster..."
if ssh rocky@$VM_IP 'sudo /usr/local/bin/k3s kubectl get nodes' &>/dev/null; then
    NODE_STATUS=$(ssh rocky@$VM_IP 'sudo /usr/local/bin/k3s kubectl get nodes -o jsonpath="{.items[0].status.conditions[?(@.type==\"Ready\")].status}"')
    echo "✅ K3s Node Status: $NODE_STATUS"
else
    echo "❌ K3s not accessible"
    exit 1
fi
echo ""

# Check MetalLB
echo "🔍 Checking MetalLB..."
METALLB_CONTROLLER=$(ssh rocky@$VM_IP 'sudo /usr/local/bin/k3s kubectl get pods -n metallb-system -l component=controller -o jsonpath="{.items[0].status.phase}"' 2>/dev/null)
METALLB_SPEAKER=$(ssh rocky@$VM_IP 'sudo /usr/local/bin/k3s kubectl get pods -n metallb-system -l component=speaker -o jsonpath="{.items[0].status.phase}"' 2>/dev/null)
if [ "$METALLB_CONTROLLER" = "Running" ] && [ "$METALLB_SPEAKER" = "Running" ]; then
    echo "✅ MetalLB Controller: $METALLB_CONTROLLER"
    echo "✅ MetalLB Speaker: $METALLB_SPEAKER"
else
    echo "❌ MetalLB not running properly"
fi
echo ""

# Check Traefik and VIP
echo "🔍 Checking Traefik and VIP..."
TRAEFIK_VIP=$(ssh rocky@$VM_IP 'sudo /usr/local/bin/k3s kubectl get svc traefik -n kube-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}"' 2>/dev/null)
if [ -n "$TRAEFIK_VIP" ]; then
    echo "✅ Traefik VIP assigned: $TRAEFIK_VIP"
else
    echo "❌ Traefik VIP not assigned"
    exit 1
fi
echo ""

# Check Rancher pods
echo "🔍 Checking Rancher..."
RANCHER_READY=$(ssh rocky@$VM_IP 'sudo /usr/local/bin/k3s kubectl get pods -n cattle-system -l app=rancher -o jsonpath="{.items[0].status.containerStatuses[0].ready}"' 2>/dev/null)
if [ "$RANCHER_READY" = "true" ]; then
    echo "✅ Rancher pod ready"
else
    echo "⚠️  Rancher pod not ready yet"
fi
echo ""

# Check Rancher ingress
echo "🔍 Checking Rancher ingress..."
INGRESS_HOST=$(ssh rocky@$VM_IP 'sudo /usr/local/bin/k3s kubectl get ingress rancher -n cattle-system -o jsonpath="{.spec.rules[0].host}"' 2>/dev/null)
INGRESS_ADDRESS=$(ssh rocky@$VM_IP 'sudo /usr/local/bin/k3s kubectl get ingress rancher -n cattle-system -o jsonpath="{.status.loadBalancer.ingress[0].ip}"' 2>/dev/null)
echo "   Hostname: $INGRESS_HOST"
echo "   Address: $INGRESS_ADDRESS"
if [ "$INGRESS_ADDRESS" = "$TRAEFIK_VIP" ]; then
    echo "✅ Ingress configured correctly"
else
    echo "❌ Ingress address mismatch"
fi
echo ""

# Test external URL access
echo "🔍 Testing external URL access..."
HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" https://$TRAEFIK_VIP -H "Host: $INGRESS_HOST" --connect-timeout 10 2>/dev/null || echo "000")
echo "   HTTP Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo "✅ Rancher is accessible!"
else
    echo "⚠️  Rancher returned unexpected status code"
fi
echo ""

# Summary
echo "=========================================="
echo "Deployment Verification Summary"
echo "=========================================="
echo "VM IP:          $VM_IP"
echo "Traefik VIP:    $TRAEFIK_VIP"
echo "Rancher URL:    https://$INGRESS_HOST"
echo "K3s Status:     $([ "$NODE_STATUS" = "True" ] && echo "✅ Ready" || echo "❌ Not Ready")"
echo "MetalLB:        $([ "$METALLB_CONTROLLER" = "Running" ] && echo "✅ Running" || echo "❌ Not Running")"
echo "Rancher:        $([ "$RANCHER_READY" = "true" ] && echo "✅ Ready" || echo "⚠️  Not Ready")"
echo "External Access: $([ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ] && echo "✅ Working" || echo "⚠️  Check Status")"
echo "=========================================="
