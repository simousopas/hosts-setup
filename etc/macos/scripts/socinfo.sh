#!/usr/bin/env bash
# shellcheck disable=SC2155

set -Eeuo pipefail

readonly CPU_BRAND=$(sysctl -n machdep.cpu.brand_string)
readonly NUM_PERF_LEVELS=$(sysctl -n hw.nperflevels)
readonly NUM_PHYSICAL_CPUS=$(sysctl -n hw.physicalcpu)
readonly NUM_GPU_CORES=$(
	system_profiler SPDisplaysDataType |
	grep "Total Number of Cores" |
	grep -oE "\d+"
)
readonly RAM_SIZE=$(sysctl -n hw.memsize)

echo -e "Designation: $CPU_BRAND";
echo -e "Memory size: $((RAM_SIZE / 1024 / 1024 / 1024))GiB";
echo -e "# CPU cores: $NUM_PHYSICAL_CPUS";
echo -e "# GPU cores: $NUM_GPU_CORES";

for ((i=0; i<NUM_PERF_LEVELS; i++))
do
	perf_level=$(sysctl -n "hw.perflevel$i.name")
	perf_level_num_cpus=$(sysctl -n "hw.perflevel$i.physicalcpu")
	perf_level_cpu_l1icache_size=$(sysctl -n "hw.perflevel$i.l1icachesize")
	perf_level_cpu_l1dcache_size=$(sysctl -n "hw.perflevel$i.l1dcachesize")
	perf_level_cpu_l2cache_size=$(sysctl -n "hw.perflevel$i.l2cachesize")
	perf_level_cpu_cluster_size=$(sysctl -n "hw.perflevel$i.cpusperl2")

	echo -e "\n--- $perf_level cores ---"
	echo -e "# CPU cores:\t\t$perf_level_num_cpus"
	echo -e "# CPU clusters:\t\t$((perf_level_num_cpus / perf_level_cpu_cluster_size))"
	echo -e "# CPU cores / cluster:\t$perf_level_cpu_cluster_size"
	echo -e "L1I\$ per CPU core:\t$((perf_level_cpu_l1icache_size / 1024))KiB"
	echo -e "L1D\$ per CPU core:\t$((perf_level_cpu_l1dcache_size / 1024))KiB"
	echo -e "L2\$ per CPU cluster:\t$((perf_level_cpu_l2cache_size / 1024 / 1024))MiB"
done
