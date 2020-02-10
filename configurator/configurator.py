import argparse
import yaml
import subprocess

ORIGIN = f"https://github.com/econ-ark/REMARK"
PR = f"39"
DOCKER_IMAGE = f"mriduls/econ-ark-notebook"

# Take the file as an argument
parser = argparse.ArgumentParser()
parser.add_argument(
    "config", help="A YAML config file for custom parameters for REMARKs"
)
args = parser.parse_args()


with open(args.config, "r") as stream:
    config_parameters = yaml.safe_load(stream)

print(config_parameters)


pwd = subprocess.run(["pwd"], capture_output=True)
mount = str(pwd.stdout)[2:-3] + ":/home/jovyan/work"
# mount the present directory and start up a container
container_id = subprocess.run(
    ["docker", "run", "-v", mount, "-d", DOCKER_IMAGE],
    capture_output=True,
)
container_id = container_id.stdout.decode("utf-8")[:-1]
# fetch the PR
subprocess.run(
    [
        f'docker exec -it {container_id} bash -c "cd REMARK; git fetch {ORIGIN} +refs/pull/{PR}/merge; git checkout FETCH_HEAD"'
    ],
    shell=True,
)
# copy the params file to params_init file
subprocess.run(
    [
        f"docker exec -it  {container_id} bash -c 'cp /home/jovyan/REMARK/REMARKs/CGMPortfolio/Code/Python/Calibration/params.py /home/jovyan/REMARK/REMARKs/CGMPortfolio/Code/Python/Calibration/params_init.py'"
    ],
    shell=True,
)
# copy the params files to current work directory
subprocess.run(
    [
        f"docker exec -it  {container_id} bash -c 'cp /home/jovyan/REMARK/REMARKs/CGMPortfolio/Code/Python/Calibration/params* /home/jovyan/work'"
    ],
    shell=True,
)
# create a directory to store results from the run
subprocess.run(
    [f"docker exec -it  {container_id} bash -c 'mkdir /home/jovyan/work/results'"],
    shell=True,
)

dict_portfolio_keys = [
    "CRRA",
    "Rfree",
    "DiscFac",
    "T_age",
    "T_cycle",
    "T_retire",
    "LivPrb",
    "PermGroFac",
    "cycles",
    "PermShkStd",
    "PermShkCount",
    "TranShkStd",
    "TranShkCount",
    "UnempPrb",
    "UnempPrbRet",
    "IncUnemp",
    "IncUnempRet",
    "BoroCnstArt",
    "tax_rate",
    "approxRiskyDstn",
    "drawRiskyFunc",
    "RiskyCount",
    "RiskyShareCount",
    "aXtraMin",
    "aXtraMax",
    "aXtraCount",
    "aXtraExtra",
    "aXtraNestFac",
    "vFuncBool",
    "CubicBool",
    "AgentCount",
    "pLvlInitMean",
    "pLvlInitStd",
    "T_sim",
    "PermGroFacAgg",
    "aNrmInitMean",
    "aNrmInitStd",
]

parameters_update = [
    "from .params_init import dict_portfolio, time_params, det_income, norm_factor"
]
for parameter in config_parameters:
    print(f"Running docker instance against parameters: {parameter} ")
    for key, val in config_parameters[parameter].items():
        # check if it's in time_params
        if key in ["Age_born", "Age_retire", "Age_death"]:
            parameters_update.append(f"time_params['{key}'] = {val}")
        # check if it's det_income
        elif key is "det_income":
            parameters_update.append(f"det_income = np.array({val})")
        # check if it's in dict_portfolio
        elif key in dict_portfolio_keys:
            parameters_update.append(f"dict_portfolio['{key}'] = {val}")
        else:
            print("Parameter provided in config file not found")
    print(parameters_update)
    with open("params.py", "w") as f:
        for item in parameters_update:
            f.write("%s\n" % item)
    # restart parameter update list
    parameters_update = parameters_update[0:1]
    # copy new parameters file to the REMARK
    subprocess.run(
        [
            f"docker exec -it  {container_id} bash -c 'cp /home/jovyan/work/params.py /home/jovyan/REMARK/REMARKs/CGMPortfolio/Code/Python/Calibration/params.py'"
        ],
        shell=True,
    )
    # remove previous figures from the REMARK
    subprocess.run(
        [
            f"docker exec -it {container_id} bash -c 'rm /home/jovyan/REMARK/REMARKs/CGMPortfolio/Code/Python/Figures/*'"
        ],
        shell=True,
    )
    subprocess.run(
        [
            f"docker exec -it {container_id} bash -c 'ls /home/jovyan/REMARK/REMARKs/CGMPortfolio/Code/Python/Figures'"
        ],
        shell=True,
    )
    # run the do_X file and get the results
    subprocess.run(
        [
            f"docker exec -it  {container_id} bash -c 'cd REMARK/REMARKs/CGMPortfolio; ipython do_MIN.py'"
        ],
        shell=True,
    )
    # create a folder to store the figures for this parameter
    subprocess.run(
        [
            f"docker exec -it  {container_id} bash -c 'mkdir /home/jovyan/work/results/figure_{parameter}'"
        ]
        shell=True,
    )
    # copy the files created in figures to results
    subprocess.run(
        [
            f"docker exec -it {container_id} bash -c 'cp /home/jovyan/REMARK/REMARKs/CGMPortfolio/Code/Python/Figures/* /home/jovyan/work/results/figure_{parameter}/'"
        ],
        shell=True,
    )


subprocess.run([f"docker stop {container_id}"], shell=True)
