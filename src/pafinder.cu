#include <chrono>
#include <cstdlib>
#include <iostream>
#include <sys/stat.h>
#include <thread>
#include <vector>

#include <cuda.h>
#include <cufft.h>

#include "config.hpp"
#include "errors.hpp"
#include "main_pool.cuh"

using std::cerr;
using std::cout;
using std::endl;
using std::string;
using std::thread;
using std::vector;

int main(int argc, char *argv[])
{
    string configfile;
    InConfig config;
    SetDefaultConfig(config);

    // too many parameters to load as arguments - use config file
    if (argc >= 2) {
        for (int iarg = 0; iarg < argc; iarg  ++) {
            if (string(argv[iarg]) == "--config") {      // configuration file
                iarg++;
                configfile = string(argv[iarg]);
                ReadConfig(configfile, config);
                //TODO: Shall we break at this point or allow to add extra or change some parameters?
            } else if (string(argv[iarg]) == "-r") {
                iarg++;
                config.record = atoi(argv[iarg]);
            } else if (string(argv[iarg]) == "-s") {     // the number of streams to use
                iarg++;
                config.nostreams = atoi(argv[iarg]);
            } else if (string(argv[iarg]) == "-b") {     // the number of beams to accept the data from
                iarg++;
                config.nobeams = atoi(argv[iarg]);
            } else if (string(argv[iarg]) == "-t") {     // the number of time sample to average
                iarg++;
                config.timeavg = atoi(argv[iarg]);
            } else if (string(argv[iarg]) == "-f") {     // the number of frequency channels to average
                iarg++;
                config.freqavg = atoi(argv[iarg]);
            } else if (string(argv[iarg]) == "-n") {    // the number of GPUs to use
                iarg++;
                config.nogpus = atoi(argv[iarg]);
                int devcount{0};
                cudaCheckError(cudaGetDeviceCount(&devcount));
                if (config.nogpus > devcount) {
                    cout << "You can't use more GPUs than you have available!" << endl;
                    config.nogpus = devcount;
                }
            } else if (string(argv[iarg]) == "-o") {    // output directory for the filterbank files
                iarg++;
                struct stat chkdir;
                if (stat(argv[iarg], &chkdir) == -1) {
                    cerr << "Stat error" << endl;
                } else {
                    bool isdir = S_ISDIR(chkdir.st_mode);
                    if (isdir)
                        config.outdir = string(argv[iarg]);
                    else
                        cout << "Output directory does not exist! Will use the default directory!";
                }
            } else if (string(argv[iarg]) == "--gpuid") {
                for (int igpu = 0; igpu < config.nogpus; igpu++) {
                    iarg++;
                    config.gpuids.push_back(atoi(argv[iarg]));
                }
            } else if (string(argv[iarg]) == "--ip") {
                for (int iip = 0; iip < config.nogpus; iip++) {
                    iarg++;
                    config.ips.push_back(string(argv[iarg]));
                }
            } else if (string(argv[iarg]) == "-v") {
                config.verbose = true;
            } else if ((string(argv[iarg]) == "-h") || (string(argv[iarg]) == "--help")) {
                cout << "Options:\n"
                        << "\t -h --help - print out this message\n"
                        << "\t --config <file name> - configuration file\n"
                        << "\t -b - the number of beams to process\n"
                        << "\t -f - the number of frequency channels to average\n"
                        << "\t -n - the number of GPUs to use\n"
                        << "\t -o <directory> - output directory\n"
                        << "\t -r - the number of seconds to record\n"
                        << "\t -s - the number of CUDA streams per GPU to use\n"
                        << "\t -t - the number of time samples to average\n"
                        << "\t -v - use verbose mode\n"
                        << "\t --gpuid - GPU IDs to use - the number must be the same as 'n'\n"
                        << "\t --ip - IPs to listen to - the number must be the same as 'n'\n\n";
                exit(EXIT_SUCCESS);
            }
        }

    }

    // TODO: Expand the configuration output a bit
    if (config.verbose) {
        cout << "Starting up. This may take few seconds..." << endl;

        cout << "This is the configuration used:" << endl;
        cout << "\t - the number of beams per node: " << config.nobeams << endl;
        cout << "\t - the number of GPUs to use: " << config.nogpus << endl;
        cout << "\t - IP addresses to listen on:" << endl;
        for (int iip = 0; iip < config.ips.size(); iip++) {
            cout << "\t\t * " << config.ips.at(iip) << endl;
        }
        cout << "\t - ports to listen on: " << endl;
        for (int iport = 0; iport < config.ports.size(); iport++) {
            cout << "\t\t * " << config.ports.at(iport) << endl;
        }
        cout << "\t - output directory: " << config.outdir << endl;
        cout << "\t - the number of seconds to record: " << config.record << endl;
        cout << "\t - frequency averaging: " << config.freqavg << endl;
        cout << "\t - time averaging: " << config.timeavg << endl;
        cout << "\t - dedispersion gulp size: " << config.gulp << endl;
        cout << "\t - first DM to dedisperse to: " << config.dmstart << endl;
        cout << "\t - last DM to dedisperse to: " << config.dmend << endl;
    }

    MainPool pafpool(config);

    cudaDeviceReset();

    return 0;
}