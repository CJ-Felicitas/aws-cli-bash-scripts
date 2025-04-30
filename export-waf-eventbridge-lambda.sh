#!/bin/bash

# Root export directory
exportDir="./aws-export"
mkdir -p "$exportDir"

########################################
# WAF EXPORT (WAFv2)
########################################
wafDir="$exportDir/waf"
mkdir -p "$wafDir"
echo -e "\nExporting WAFv2 resources..."

wafScope="REGIONAL"  # or CLOUDFRONT

webAcls=$(aws wafv2 list-web-acls --scope "$wafScope")
echo "$webAcls" | jq '.' > "$wafDir/webacls.json"

webAclDetails="[]"
for row in $(echo "$webAcls" | jq -r '.WebACLs[] | @base64'); do
    _jq() {
        echo "$row" | base64 --decode | jq -r "$1"
    }

    name=$(_jq '.Name')
    id=$(_jq '.Id')

    detail=$(aws wafv2 get-web-acl --scope "$wafScope" --name "$name" --id "$id")
    webAclDetails=$(echo "$webAclDetails" | jq ". + [$detail]")
done
echo "$webAclDetails" | jq '.' > "$wafDir/webacls-detailed.json"

ipSets=$(aws wafv2 list-ip-sets --scope "$wafScope")
echo "$ipSets" | jq '.' > "$wafDir/ipsets.json"

ipSetDetails="[]"
for row in $(echo "$ipSets" | jq -r '.IPSets[] | @base64'); do
    _jq() {
        echo "$row" | base64 --decode | jq -r "$1"
    }

    name=$(_jq '.Name')
    id=$(_jq '.Id')

    detail=$(aws wafv2 get-ip-set --scope "$wafScope" --name "$name" --id "$id")
    ipSetDetails=$(echo "$ipSetDetails" | jq ". + [$detail]")
done
echo "$ipSetDetails" | jq '.' > "$wafDir/ipsets-detailed.json"

ruleGroups=$(aws wafv2 list-rule-groups --scope "$wafScope")
echo "$ruleGroups" | jq '.' > "$wafDir/rule-groups.json"

ruleGroupDetails="[]"
for row in $(echo "$ruleGroups" | jq -r '.RuleGroups[] | @base64'); do
    _jq() {
        echo "$row" | base64 --decode | jq -r "$1"
    }

    name=$(_jq '.Name')
    id=$(_jq '.Id')

    detail=$(aws wafv2 get-rule-group --scope "$wafScope" --name "$name" --id "$id")
    ruleGroupDetails=$(echo "$ruleGroupDetails" | jq ". + [$detail]")
done
echo "$ruleGroupDetails" | jq '.' > "$wafDir/rule-groups-detailed.json"

########################################
# EVENTBRIDGE SCHEDULER EXPORT
########################################
eventBridgeDir="$exportDir/eventbridge"
mkdir -p "$eventBridgeDir"
echo -e "\nExporting EventBridge Scheduler..."

scheduleGroups=$(aws scheduler list-schedule-groups)
echo "$scheduleGroups" | jq '.' > "$eventBridgeDir/schedule-groups.json"

schedules=$(aws scheduler list-schedules)
echo "$schedules" | jq '.' > "$eventBridgeDir/schedules.json"

detailedScheduleData="[]"
for row in $(echo "$schedules" | jq -r '.Schedules[] | @base64'); do
    _jq() {
        echo "$row" | base64 --decode | jq -r "$1"
    }

    name=$(_jq '.Name')
    groupName=$(_jq '.GroupName')

    detail=$(aws scheduler get-schedule --name "$name" --group-name "$groupName")
    detailedScheduleData=$(echo "$detailedScheduleData" | jq ". + [$detail]")
done
echo "$detailedScheduleData" | jq '.' > "$eventBridgeDir/schedules-detailed.json"

########################################
# LAMBDA EXPORT
########################################
lambdaDir="$exportDir/lambda"
mkdir -p "$lambdaDir/code"
echo -e "\nExporting Lambda functions and downloading code..."

functions=$(aws lambda list-functions)
echo "$functions" | jq '.' > "$lambdaDir/lambda-functions.json"

lambdaDetails="[]"
for row in $(echo "$functions" | jq -r '.Functions[] | @base64'); do
    _jq() {
        echo "$row" | base64 --decode | jq -r "$1"
    }

    functionName=$(_jq '.FunctionName')
    echo "Downloading code for Lambda: $functionName"

    config=$(aws lambda get-function --function-name "$functionName")
    lambdaDetails=$(echo "$lambdaDetails" | jq ". + [$config]")

    codeLocation=$(echo "$config" | jq -r '.Code.Location')
    curl -s -o "$lambdaDir/code/${functionName}.zip" "$codeLocation"
done

echo "$lambdaDetails" | jq '.' > "$lambdaDir/lambda-functions-detailed.json"

echo -e "\nExport complete. Files saved in: $exportDir"
