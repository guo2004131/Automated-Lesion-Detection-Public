function ALD_GenerateAverageMRI(job)
healthy_filenames = job.HealthyMRI;
withskull = job.withskull;

GenerateHealtyAverageMRI(healthy_filenames,withskull);