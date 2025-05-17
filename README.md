# Terraform IOT/ML AWS Infrastructure

High level goal is to run IOT/ML infrastructure in AWS. These are the resources we need to achieve this.   
1. Deploy a AWS IoT core to enable device registration.
2. Device registration with certificates. Use this certificate in your actual arduino or raspberry device.
3. Stream the data from the IoT device to a Lambda to apply ML.

## How to customize it
1. Change your device name and type thing in `variables.tf`.   
2. Download the certificate after applying the infrastructure and use this for your Arduino/Raspberry Device.
3. Make sure the device sends the data to your own topic. By default, I made the topic to which it send the data is `sensors/temperature`. 
4. Use this Link **[[Connecting your device](https://docs.arduino.cc/tutorials/opta/getting-started-with-aws-iot-core/#connecting-your-device-to-aws-iot-core)]** for your arduino device. 
5. Customize the python file `hello-world.py` and apply your own ML algorithm in the function. 
6. To secure my infrastructure, I have my own values for `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` variables in terraform cloud as a sensitive variables. Use your AWS Account credentials to apply this terraform code in your AWS account.