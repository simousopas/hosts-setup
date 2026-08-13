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
echo -e "# GPU cores: ${NUM_GPU_CORES:-Unknown / Not Applicable}";

for ((i=0; i<NUM_PERF_LEVELS; i++))
do
	perf_level=$(sysctl -n "hw.perflevel$i.name")
	perf_level_num_cpus=$(sysctl -n "hw.perflevel$i.physicalcpu")
	perf_level_cpu_l1icache_size=$(sysctl -n "hw.perflevel$i.l1icachesize")
	perf_level_cpu_l1dcache_size=$(sysctl -n "hw.perflevel$i.l1dcachesize")
	perf_level_cpu_l2cache_size=$(sysctl -n "hw.perflevel$i.l2cachesize")
	perf_level_cpu_cluster_size=$(sysctl -n "hw.perflevel$i.cpusperl2")

	num_cores=$perf_level_num_cpus
	num_clusters=$((perf_level_num_cpus / perf_level_cpu_cluster_size))
	num_cores_cluster=$perf_level_cpu_cluster_size
	l1isize_kib=$((perf_level_cpu_l1icache_size / 1024))
	l1dsize_kib=$((perf_level_cpu_l1dcache_size / 1024))
	l2size_kib=$((perf_level_cpu_l2cache_size / 1024))
	l1isize_total_kib=$((l1isize_kib * num_cores))
	l1dsize_total_kib=$((l1dsize_kib * num_cores))
	l2size_total_kib=$((l2size_kib * num_clusters))

	echo -e "\n--- $perf_level group ---"
	echo -e "# CPU cores:\t\t$num_cores"
	echo -e "# CPU clusters:\t\t$num_clusters"
	echo -e "# Cores / Cluster:\t$num_cores_cluster"
	echo -e "L1I\$ per core:\t\t${l1isize_kib}KiB (Total of ${l1isize_total_kib}KiB)"
	echo -e "L1D\$ per core:\t\t${l1dsize_kib}KiB (Total of ${l1dsize_total_kib}KiB)"
	if [[ $l2size_kib -ge 1024 ]]; then
		l2size_mib=$((l2size_kib / 1024))
		l2size_total_mib=$((l2size_total_kib / 1024))
		echo -e "L2\$ per cluster:\t${l2size_mib}MiB (Total of ${l2size_total_mib}MiB)"
	else
		echo -e "L2\$ per cluster:\t${l2size_kib}KiB (Total of ${l2size_total_kib}KiB)"
	fi
done
