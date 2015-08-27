PATH = '/n/regal/rycroft_lab/jordan/full_ax_ex_4'
iterations = str(15)
Max_T = 300

def submit(time):
        t=str(time)
        return "#!/bin/bash \n#SBATCH -J im_"+t+"\n#SBATCH -N 1\n#SBATCH -n 25\n#SBATCH -t 3-00:00\n#SBATCH -p general\n#SBATCH --mem=100000\n#SBATCH -o out_"+t+".out\n#SBATCH -e err_"+t+".err\nexport DISPLAY=:"+t+"\nXvfb $DISPLAY -auth /dev/null &\n/n/home11/jhoffmann/Fiji/Fiji.app/ImageJ-linux64 --memory=100000m -macro ./time_"+t+".ijm"
def do_tp(time):
        t = str(time)
        return 'run("Fuse/Deconvolve Dataset", "browse='+PATH+'/dataset.xml select_xml='+PATH+'/dataset.xml process_angle=[All angles] process_channel=[Single channel (Select from List)] process_illumination=[All illuminations] process_timepoint=[Single Timepoint (Select from List)] processing_channel=[channel 1] processing_timepoint=[Timepoint '+t+'] type_of_image_fusion=[Multi-view deconvolution] bounding_box=[Define manually] fused_image=[Save as TIFF stack] minimal_x=130 minimal_y=30 minimal_z=-65 maximal_x=780 maximal_y=1860 maximal_z=600 imglib2_container=[CellImg (large images)] imglib2_container_ffts=ArrayImg save_memory type_of_iteration=[Efficient Bayesian - Optimization I (fast, precise)] image_weights=[Virtual weights (less memory, slower)] osem_acceleration=[1 (balanced)] number_of_iterations='+iterations+' use_tikhonov_regularization tikhonov_parameter=0.0060 compute=[Entire image at once] compute_on=[CPU (Java)] psf_estimation=[Provide file with PSF] psf_display=[Do not show PSFs] output_file_directory='+PATH+'/decon_15/ use_same_psf_for_all_angles/illuminations browse=['+PATH+'/psf.tif] transform_psfs psf_file=['+PATH+'/psf.tif]");'

if __name__ == '__main__':
        for TIME in xrange(1,Max_T+1):
                text_file = open("time_"+str(TIME)+".ijm", "w")
                string = do_tp(TIME)
                text_file.write(string)
                text_file.close()
                text_file2 = open("submit_"+str(TIME), "w")
                string2 = submit(TIME)
                text_file2.write(string2)
                text_file2.close()

