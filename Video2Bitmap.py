import cv2, os, time
#os.chdir(os.path.realpath(__file__))

final_size = (50,50)

file_path = "D:/SteamLibrary/steamapps/common/GearBlocks/canvas.lua"

def writefile(frame):
    file = open(file_path,"w")
    cv2.imshow('Overlay', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        exit()
    frame = cv2.resize(frame, final_size)
    write_out = "return {"
    for y in range(final_size[1]):
        write_out+="{"
        for x in range(final_size[0]):
            r,g,b = frame[y, x]
            if r+g+b > 0:
                write_out+="true,"
            else:
                write_out+="false,"
        write_out+="},"
    write_out+="}"
    file.write(write_out)
    print("frame")
    file.close()
    time.sleep(1/fps)

Video_path = "./Bad Apple.mp4"

video_capture = cv2.VideoCapture(Video_path)
fps = int(video_capture.get(cv2.CAP_PROP_FPS))
success, frame = video_capture.read()
writefile(frame)


while success:
        # Read the next frame
        writefile(frame)
        success, frame = video_capture.read()
video_capture.release()
cv2.destroyAllWindows()