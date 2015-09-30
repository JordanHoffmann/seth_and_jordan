import h5py
import skfmm
import numpy as np
import matplotlib.pyplot as plt
import cv2
from scipy import ndimage as ndi
from skimage.morphology import watershed
from skimage.feature import peak_local_max
import scipy.ndimage
ch1 = h5py.File('./26spim_TL001_Channel1_Angle1_Simple Segmentation.h5','r')
ch2 = h5py.File('./26spim_TL001_Channel2_Angle1_Simple Segmentation.h5','r')


'''
************************************************
PARAMETERS
************************************************
'''
rad_tol = 30
'''
************************************************
************************************************
'''

def import_data():
	print ch1
	print ch2
	data1 = np.array(ch1["exported_data"])
	data2 = np.array(ch2["exported_data"])
	print np.shape(data1)
	print np.shape(data2)

	slice1 = np.zeros((1024,1024))
	slice2 = np.zeros((1024,1024))

	t = 35
	for i in xrange(1024):
		for j in xrange(1024):
			slice1[i][j] = data1[t][i][j][0]-1
			slice2[i][j] = data2[t][i][j][0]-1
	print np.shape(slice1)
	return slice1,slice2

def pre_process(slice1,slice2):
	#nuclei in slice 1
	#membrane in slice 2
	(d1,d2) = np.shape(slice1)
	print 'd1 is: ' , d1
	print 'd2 is: ', d2
	for i in xrange(int(d1)):
		for j in xrange(int(d2)):
			# print slice1[i][j]
			# print slice2[i][j]
			# exit()
			if int(slice1[i][j]) == int(1) and int(slice2[i][j]) == int(1):
				slice1[i][j] = 0
	#If both nucleus and membrane, remove nucleus.
	return slice1,slice2

def watershed_seg(slice1):
	slice1 = np.transpose(slice1)
	slice1t = scipy.ndimage.filters.gaussian_filter(slice1,0.25)
	slice1 = np.copy(slice1t)
	distance = ndi.distance_transform_edt(slice1)
	local_maxi = peak_local_max(distance, indices=False, footprint=np.ones((3, 3)), labels=slice1)
	markers = ndi.label(local_maxi)[0]
	labels = watershed(-distance, markers, mask=slice1)
	'''
	For debugging
	'''
	fig, axes = plt.subplots(ncols=3, figsize=(8, 2.7))
	ax0, ax1, ax2 = axes
	ax0.imshow(slice1, cmap=plt.cm.gray, interpolation='nearest')
	ax0.set_title('Overlapping objects')
	ax1.imshow(-distance, cmap=plt.cm.jet, interpolation='nearest')
	ax1.set_title('Distances')
	ax2.imshow(labels, cmap=plt.cm.spectral, interpolation='nearest')
	ax2.set_title('Separated objects')
	for ax in axes:
	    ax.axis('off')
	fig.subplots_adjust(hspace=0.01, wspace=0.01, top=0.9, bottom=0, left=0, right=1)
	plt.show()
	'''
	end
	'''
	locs = [[] for i in xrange(int(np.amax(markers)))]
	for i in xrange(1024):
		for j in xrange(1024):
			if int(labels[i][j]) != 0:
				ID = int(labels[i][j])
				locs[ID-1].append([i,j])
	centroids = [np.zeros(2) for i in xrange(int(np.amax(markers)))]
	for i in xrange(len(locs)):
		xs,ys = np.transpose(np.array(locs[i]))
		centroids[i][0] = np.mean(xs)
		centroids[i][1] = np.mean(ys)
   	return np.array(centroids)

def remove_some(centroids):
	cents = [[[centroids[0][0],centroids[0][1]]]]
	for i in xrange(1,len(centroids)):
		flag = False
		for j in xrange(len(cents)):
			for k in xrange(len(cents[j])):
				d = (cents[j][k][0]-centroids[i][0])**2+(cents[j][k][1]-centroids[i][1])**2
				if np.sqrt(d) < rad_tol:
					flag = True
		if flag == False:
			cents.append([[centroids[i][0],centroids[i][1]]])
	#print cents
	print 'Now have only: ', len(cents)
	#exit()
	return cents

def get_membrane_boundaries(centroids,membrane_background):
	print np.shape(membrane_background)
	#setup solution array
	scale_up = 3
	print scale_up*np.shape(membrane_background)
	sols = np.array(np.shape(membrane_background))
	return 0

def extract_ridges(mat):
	shap = np.shape(mat)
	tmp = np.zeros(shap)
	print np.shape(tmp)
	for i in xrange(1,shap[0]-1):
		for j in xrange(1,shap[0]-1):
			if ((mat[i][j-1] < mat[i][j]) and  (mat[i][j+1]<mat[i][j])):
				tmp[i][j] = 1
			if ((mat[i-1][j] < mat[i][j]) and  (mat[i+1][j]<mat[i][j])):
				tmp[i][j] = 1
	tmp2 = scipy.ndimage.filters.gaussian_filter(tmp,2)
	plt.spy(tmp)
	plt.show()
	plt.imshow(tmp2)
	plt.show()
	# shap = np.shape(mat)
	# tmp3 = np.zeros(shap)
	# print np.shape(tmp)
	# for i in xrange(1,shap[0]-1):
	# 	for j in xrange(1,shap[0]-1):
	# 		if ((np.transpose(mat)[i][j-1] < np.transpose(mat)[i][j]) and  (np.transpose(mat)[i][j+1]<np.transpose(mat)[i][j])):
	# 			tmp3[j][i] = 1

	# plt.spy(tmp3+tmp)
	# plt.show()
	# tmp2 = scipy.ndimage.filters.gaussian_filter(tmp3+tmp,2)
	# plt.imshow(tmp2)
	# plt.show()


if __name__=='__main__':
	slice1,slice2 = import_data()
	slice1,slice2 = pre_process(slice1,slice2)
	slice2 = scipy.ndimage.filters.gaussian_filter(slice2,2)
	plt.imshow(slice2)
	plt.show()
	centroids = watershed_seg(slice1)
	print np.shape(centroids)
	print	centroids[0]
	print np.amax(centroids)

	centroids = remove_some(centroids)
	centroids = np.array(centroids).flatten()
	centroids = centroids.reshape(len(centroids)/2,2)
	cx,cy = np.transpose(centroids)
	plt.imshow(slice2)
	plt.scatter(x=cx, y=cy, c='g', s=14)
	plt.show()


	fmm = np.ones((1024,1024))
	for i in xrange(len(centroids)):
		x1 = int(centroids[i][0])
		y1 = int(centroids[i][1])
		fmm[y1][x1] = -1
	dist_mat = skfmm.distance(fmm)
	plt.imshow(dist_mat)
	plt.show()
	speed = 1 - np.copy(slice2) + 0.1
	print np.amax(slice2)
	print np.amin(slice2)
	print np.amax(speed)
	print np.amin(speed)
	t = skfmm.travel_time(fmm, speed)
	print np.shape(t)
	plt.imshow(t)
	plt.show()
	plt.plot(t[100])
	plt.show()
	plt.contour(np.flipud(t), 55)
	plt.colorbar()
	plt.show()
	extract_ridges(t)
	#centroids = remove_some(centroids)
	#centroids = np.array(centroids).flatten()
	#centroids = centroids.reshape(len(centroids)/2,2)
	#cx,cy = np.transpose(centroids)
	#plt.imshow(slice2)
	#plt.scatter(x=cx, y=cy, c='g', s=14)
	#plt.show()
	#get_membrane_boundaries(centroids,slice2)



