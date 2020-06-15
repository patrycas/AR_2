
%First of all take the colum B od the data.xlsx

stock_price= xlsread('data.xlsx','Data','B:B'); 

%transform the data into log return

data=diff(log(stock_price));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%1) plot the serie
plot(data(1:end));
title('Log stock/price');
size(data);

%2)State the conditions under which the process is causal and stationary.
mdl = arima(2,0,0); % 2 the lag order
EstMdl = estimate(mdl,data); % data is your data

%3)Estimate the parameters c and beta with OLS.

%target 
y=data(3:end,1);

% generation of the lags
x=[];
for j=1:2
    x=[x data(2-j+1:end-j,1)]; 
end

% adding a column of one in order to estimate the consant with OLS
T=size(y,1); 
x=[ones(T,1) x];

% OLS estimates
b=inv(x'*x)*x'*y


%4)Compute the roots of the AR polynomial.

%first we need to order the polynomial

%specifying the coefficients in the righ order
poly = [-flip(b(2:end)); 1]
%absolute value of the roots of the lag polynomial
abs(roots(poly))


% 5)(e) Estimate and plot the first 10 autocorrelations (using the theoret-
%ical formula for the AR(2)).

%we know that phi(0)=1, phi(1)= theta(1)/1-theta(2)
p=0;  
for k = 3:10
    p(1)=1
    p(2)=(1.2826/(1+0.2822)) 
   % p(3)=((1.2826)^2/(1+0.2822))-0.2822 
   p(k)=1.2826*p(k-1) -0.2822*p(k-2)
   
end
figure
autocorr(p)


%6)Obtain and plot the coefcients of the associated MA representaion
%(companion form is very useful).

F=[b(2:end)';eye(1) zeros(1,1)];
%F power of F
q=10
w=[]
for j=1:q
    W=F^(j-1);
    w(j)=W(1,1);
end
plot(w,"-bo")
xlabel('Dimension of the Coefficient')
ylabel('Index of the Coefficient')

%(g) Using the whole sample, forecast returns up to 12 periods ahead. Plot the forecast.
y_forecast=0;  
 y_forecast(1)= 0.0028 + 0.3067*y(end,1) -0.0823*y(end-1,1)
 y_forecast(2)= 0.0028 + 0.3067* y_forecast(1) -0.0823*y(end,1)
for k = 3:12
   
    y_forecast(k)= 0.0028 + 0.3067*y_forecast(k-1) - 0.0823*y_forecast(k-2)
    plot(y_forecast)
    xlabel('period')
    ylabel('Forecast')
   
end
mdl = arima(2,0,0); % 2 the lag order
EstMdl = estimate(mdl,data); % data is your data


%y_aa=data(1:end)
%K = 12;
%p = forecast(EstMdl,y_aa,K);

%[Y]=forecast(EstMdl,12,'Y0',data)

%(h) Compute the MSE associated to the 1 and 4-step ahead out-of-
%sample forecast using half of the sample for the initial estimation
%and half for the evaluation.
initial=1
final=1778/2
  

for i=initial:final

    y_estimation=data(3:i,1)  

    x_estimation=[];
    
    for j=1:2
        x_estimation=[x_estimation data(2-j+1:i-j,1)];
    end


    T=size(y_estimation,1); 
    x_estimation=[ones(T,1) x_estimation];

    b_estimation=inv(x_estimation'*x_estimation)*x_estimation'*y_estimation;
   
    
    
    c_estimation=  b_estimation(1,1);
    phi1_estimation=b_estimation(2,1);
    phi2_estimation=b_estimation(3,1);
end
    %% Now, i do forecast for 1-step and 4-step 
y_hat=0;
y_hat(1)= c_estimation + phi1_estimation *y_estimation(end,1) + phi2_estimation*y_estimation(end-1,1)
y_hat(2)=c_estimation + phi1_estimation *y_hat(1) + phi2_estimation*y_estimation(end,1)

for k = 3:5
   
    y_hat(k)= c_estimation + phi1_estimation *y_estimation(k-1) + phi2_estimation*y_estimation(k-2)
  
   
end
y_hat(1)
y_hat(4)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1-h step
%%Now we compute the error
% for that we take the true values and for 1-h step is equal to
% y(t+1)=data(890,1)
y_1h= data(final+1,1)

%So, the error term for 1h-step is e(1)=y_(1)-y_hat(1)

e_1h=y_1h-y_hat(1)
  
%The square
(e_1h)^2
%[Y]=forecast(EstMdl,12,'Y0',data)
    
%% 4-h step
%%Now we compute the error

% for that we take the true values and for 4-h step is equal to
% y(t+1)=data(893,1)(final+4)
y_4h= data(final+4,1)
%So, the error term for 1h-step is e(1)=y_(1)-y_hat(1)

e_4h=y_4h-y_hat(4)
  
%The square

(e_4h)^2


%% MSE for 1h step and 4h step 
MSE_1_4= ((e_1h) ^2+(e_4h)^2)/(1778-final)


