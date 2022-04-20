# import required packages
import argparse
import os
import sys
import requests
import json
import time
import re

sys.path.append(os.path.dirname(os.path.realpath(__file__)) + '/requests')

# Work around for PYTHON SSL bug.
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.poolmanager import PoolManager
import ssl

class MyAdapter(HTTPAdapter):
    def init_poolmanager(self, connections, maxsize, block=False):
        self.poolmanager = PoolManager(num_pools=connections,
                                       maxsize=maxsize,
                                       block=block,
                                       ssl_version=ssl.PROTOCOL_TLSv1)


def set_server(server="", user="", passwd=""): 
    # More workarounds
    global s
    s = requests.Session()
    s.mount('https://', MyAdapter())

    vmanager_server = server

    # disable the security warnings
    requests.packages.urllib3.disable_warnings()

    # Setup URL to the vManager server.
    global rest_url
    rest_url = "https://" + vmanager_server + '/vmgr/vapi/rest'

    global authentication 
    authentication = (user, passwd)

    global headers
    headers = {'content-type':'application/json'}

# Error handling if the vAPI returns an error.
def error(response):
    print("Failed: (" +response.reason + " : " +  str(response.status_code) +")")
    print(response.text)
    sys.exit(response.status_code)

#def check_response(response):
#    # Check the response for errors.
#    if ( response.status_code != 200 and response.status_code != 204 ):
#            error(response)
#    elif response.status_code == 204:
#        print("Ok. No response on output")

def post(url, request, debug=0):
    # new post used to handle python bug.
    data = json.dumps(request)

    if debug:
        print("POST:" + rest_url + url)
        print("DATA:" + str(data))
        
    response = s.post(rest_url+url, data=data, headers=headers, auth=authentication, verify=False)

    # Retry command on 503/504 errors (connection reset & timeout waiting for bridge)
    while response.status_code in [503, 504]:
        print("*W: " + str(response.status_code) + " error on vAPI " + url + " command, retrying...")
        time.sleep(120)
        response = s.post(rest_url+url, data=data, headers=headers, auth=authentication, verify=False)

    if (response.status_code != 200 and response.status_code != 204):
        error(response)
    else:
        return response


def get(url, parameters=""):
    headers={'content-type':'application/json'}

    response = [{}]
    try:
        response = s.get(rest_url+url+parameters,headers=headers,auth=authentication,verify=False)
    except requests.exceptions.RequestException:
        print("Failed: (" +response.reason + " : " +  str(response.status_code) +")")
        print("Failure reason:\n" + response.text + "\n")
        print("url:"+rest_url+url+parameters+"\n")
        sys.exit(response.status_code)

    return response


def chained_filter(condition, chain):
    """
    Create a chained filter.
    e.g.
    chained_filter("AND",[
                in_filter("IN","status",["passed"]),
                expression_filter("parent_session_name",session_exp)
                ]
    """

    filter = {
        "@c":".ChainedFilter",
        "condition":condition,
        "chain": chain
    }
    return filter


def in_filter(operand, attname, values):
    """
    Create an IN filter
    operand values: IN | NOT_IN
    e.g. in_filter("IN","status","passed"),
    """

    filter = {
        "@c":".InFilter",
        "operand":operand,
        "attName":attname,
        "values":values
    }
    return filter


def att_value_filter(operand, attname, attvalue):
    """
    Create an Attribute value filter
    operand values: EQUALS | NOT_EQUALS | GREATER_THAN | GREATER_OR_EQUALS_TO | LESS_THAN | LESS_OR_EQUALS_TO
    e.g. att_value_filter("EQUALS","id",44)
    """

    filter = {
        "@c": ".AttValueFilter",
        "operand": operand,
        "attName": attname,
        "attValue":  attvalue,
    }
    return filter


def update_session(session_name, update_field, update_value):
    description = "Find the session by name, update the field with the value"

    request = {
        "rs":{
            "filter" : att_value_filter("EQUALS", "name", session_name)
        },
        "update":{update_field:update_value}
    }
    post('/sessions/update', request)


def code_cov(session_name, refine, hierarchy="Instances", status=["passed"]):
    description = "Get Code Coverage data and set attributes with the metrics"

    # get all sessions that match a filter
    request = {
        "sticky-context" : {
            "runs-rs" :  {
                "filter" : chained_filter("AND", [
                        in_filter("IN", "status", status),
                        att_value_filter("EQUALS", "parent_session_name", session_name)
                        ]),
            },
            "refinement-files" : refine,
        },
        "hierarchy" : hierarchy
    }

    # Get the metrics
    response = post(url='/metrics/get', request=request)
    #check_response(response);
    
    if response != None:
        # print(response.status_code)
        if response.status_code == 200:
            response_json = response.json()
            #print(json.dumps(response_json, indent=4, sort_keys=True, separators = (",", ":")))
            print("Code   Cov = %.2f%% (%d/%d)" % (response_json["code_grade"],       response_json["code_hit"],       response_json["code_total"]))
            print("Block  Cov = %.2f%% (%d/%d)" % (response_json["block_grade"],      response_json["block_hit"],      response_json["block_total"]))
            print("Expr   Cov = %.2f%% (%d/%d)" % (response_json["expression_grade"], response_json["expression_hit"], response_json["expression_total"]))
            print("Toggle Cov = %.2f%% (%d/%d)" % (response_json["toggle_grade"],     response_json["toggle_hit"],     response_json["toggle_total"]))
            print("FSM    Cov = %.2f%% (%d/%d)" % (response_json["fsm_grade"],        response_json["fsm_hit"],        response_json["fsm_total"]))

            if (response_json["code_total"] > 0):
                update_session(session_name=session_name,
                               update_field="regr_code_cov",
                               update_value=("%.2f%% (%d/%d)" % (response_json["code_grade"], response_json["code_hit"], response_json["code_total"])))
            else:
                update_session(session_name=session_name,
                               update_field="regr_code_cov",
                               update_value=("n/a"))

            if (response_json["block_total"] > 0):
                update_session(session_name=session_name,
                               update_field="regr_block_cov",
                               update_value=("%.2f%% (%d/%d)" % (response_json["block_grade"], response_json["block_hit"], response_json["block_total"])))
            else:
                update_session(session_name=session_name,
                               update_field="regr_block_cov",
                               update_value=("n/a"))
                
            if (response_json["expression_total"] > 0):
                update_session(session_name=session_name,
                               update_field="regr_expr_cov",
                               update_value=("%.2f%% (%d/%d)" % (response_json["expression_grade"], response_json["expression_hit"], response_json["expression_total"])))
            else:
                update_session(session_name=session_name,
                               update_field="regr_expr_cov",
                               update_value=("n/a"))

            if (response_json["toggle_total"] > 0):
                update_session(session_name=session_name,
                               update_field="regr_toggle_cov",
                               update_value=("%.2f%% (%d/%d)" % (response_json["toggle_grade"], response_json["toggle_hit"], response_json["toggle_total"])))
            else:
                update_session(session_name=session_name,
                               update_field="regr_toggle_cov",
                               update_value=("n/a"))

            if (response_json["fsm_total"] > 0):
                update_session(session_name=session_name,
                               update_field="regr_fsm_cov",
                               update_value=("%.2f%% (%d/%d)" % (response_json["fsm_grade"], response_json["fsm_hit"], response_json["fsm_total"])))
            else:
                update_session(session_name=session_name,
                               update_field="regr_fsm_cov",
                               update_value=("n/a"))


def vplan_cov(session_name, vplan, refine, hierarchy="", status=["passed"]):
    description = "Get vPlan Coverage data and set attributes with the metrics"

    if (str(vplan) != "None"):
        # get all sessions that match a filter
        request = {
            "sticky-context" : {
                "vplan" : vplan,
                "runs-rs" :  {
                    "filter" : chained_filter("AND", [
                        in_filter("IN", "status", status),
                        att_value_filter("EQUALS", "parent_session_name", session_name)
                        ]),
                    },
                "vplan-refinement-files" : refine
                },
            "hierarchy" : hierarchy
            }
        
        # Get the metrics
        response = post(url='/vplan/get', request=request)
        
        if response != None:
            #print(response.status_code)
            if response.status_code == 200:
                response_json = response.json()
                #print(json.dumps(response_json, indent=4, sort_keys=True, separators = (",", ":")))
                print("vPlan Mapping     = %.2f%% (%d/%d)" % (response_json["mapped_elements_grade"], response_json["mapped_elements"], response_json["planned_elements_accumulated"]))
                print("vPlan Cov         = %.2f%% (%d/%d)" % (response_json["overall_grade"], response_json["overall_hit"], response_json["overall_total"]))
                print("vPlan CoverGroups = %.2f%% (%d/%d)" % (response_json["cover_group_grade"], response_json["cover_group_hit"], response_json["cover_group_total"]))
                print("vPlan Assertions  = %.2f%% (%d/%d)" % (response_json["assertion_grade"], response_json["assertion_hit"], response_json["assertion_total"]))

                if (response_json["planned_elements_accumulated"] > 0):
                    update_session(session_name=session_name,
                                   update_field="regr_vplan_mapping",
                                   update_value=("%.2f%% (%d/%d)" % (response_json["mapped_elements_grade"], response_json["mapped_elements"], response_json["planned_elements_accumulated"])))
                else:
                    update_session(session_name=session_name,
                                   update_field="regr_vplan_mapping",
                                   update_value=("n/a"))
                    
                if (response_json["overall_total"] > 0):
                    update_session(session_name=session_name,
                                   update_field="regr_vplan_cov",
                                   update_value=("%.2f%% (%d/%d)" % (response_json["overall_grade"], response_json["overall_hit"], response_json["overall_total"])))
                else:
                    update_session(session_name=session_name,
                                   update_field="regr_vplan_cov",
                                   update_value=("n/a"))
                        
                if (response_json["cover_group_total"] > 0):
                    update_session(session_name=session_name,
                                   update_field="regr_vplan_cover_group",
                                   update_value=("%.2f%% (%d/%d)" % (response_json["cover_group_grade"], response_json["cover_group_hit"], response_json["cover_group_total"])))
                else:
                    update_session(session_name=session_name,
                                   update_field="regr_vplan_cover_group",
                                   update_value=("n/a"))   
                            
                if (response_json["assertion_total"] > 0):
                    update_session(session_name=session_name,
                                   update_field="regr_vplan_assertion",
                                   update_value=("%.2f%% (%d/%d)" % (response_json["assertion_grade"], response_json["assertion_hit"], response_json["assertion_total"])))
                else:
                    update_session(session_name=session_name,
                                   update_field="regr_vplan_assertion",
                                   update_value=("n/a"))
    else:
        # No vPlan specified, enter it all as NA
        update_session(session_name=session_name, update_field="regr_vplan_mapping",     update_value=("n/a"))
        update_session(session_name=session_name, update_field="regr_vplan_cov",         update_value=("n/a"))
        update_session(session_name=session_name, update_field="regr_vplan_cover_group", update_value=("n/a"))
        update_session(session_name=session_name, update_field="regr_vplan_assertion",   update_value=("n/a"))
        

def get_tracking_config(project_name):
    description = "Get the tracking configuration info and return it"

    # Get the config
    # curl -u script_user:letmein -k -X GET "https://vlsj-fastfe-vmgr.cadence.com:8080/vmgr/vapi/rest/tracking-configuration/get?projectName=SHA" -H "accept: application/json"
    get_parameters = "?projectName=" + project_name
    response = get(url='/tracking-configuration/get', parameters=get_parameters)

    if response != None:
        if response.status_code == 200:
            response_json = response.json()
            #print(json.dumps(response_json, indent=4, sort_keys=True, separators = (",", ":")))
            print("vPlan        = " + str(response_json["vplanPath"]))
            print("vPlan Refine = " + str(response_json["vplanRefinementFiles"]))
            print("Refine       = " + str(response_json["metricRefinementFiles"]))
            return response_json
        else:
            error(response)
    else:
        error(response)
            

################################################################################
parser = argparse.ArgumentParser()
parser.add_argument("session_name", help="Session to calculate vPlan mapping percentage for")
parser.add_argument("config_name",  help="Tracking Configuration name")
parser.add_argument("server",       help="vManager Server")
args = parser.parse_args()


set_server(server=args.server, user='script_user', passwd='letmein')
tc_response = get_tracking_config(project_name=args.config_name)
code_cov(session_name=args.session_name, refine=tc_response["metricRefinementFiles"])
vplan_cov(session_name=args.session_name, vplan=tc_response["vplanPath"], refine=tc_response["vplanRefinementFiles"])
